const std = @import("std");

const Exception = @import("exception").Exception;

// AI-generated test

const MyError = error{
    NotFound,
    PermissionDenied,
};

// "ResultI32" is Exception of:
// - ok type:       i32
// - error tag set: MyError
// - payload:       []const u8 (a string message / context)
const ResultI32 = Exception(i32, MyError, []const u8);

// ---------------------------------------
// Runtime demo: `zig build run`
// ---------------------------------------
pub fn main() !void {
    // 1. Successful value
    const good = ResultI32.ok(123);

    // you can unwrap via .get() like a normal Zig error union:
    const value = try good.get(); // returns i32 in this branch
    std.debug.print("good.get() -> {d}\n", .{value});

    // or explicitly:
    const good_val = try good.get_ok();
    std.debug.print("good.get_ok() -> {d}\n", .{good_val});

    // 2. Error value
    const bad = ResultI32.err(MyError.NotFound, "file.txt missing");

    // Pattern match the error-union returned by get():
    if (bad.get()) |ok_val| {
        // This branch won't run for `bad`, but let's show how it'd look.
        std.debug.print("bad.get() unexpectedly succeeded: {d}\n", .{ok_val});
    } else |err_tag| {
        // err_tag is of type MyError
        std.debug.print(
            "bad.get() returned error: {s}\n",
            .{@errorName(err_tag)},
        );

        // We can still inspect the payload with get_err():
        const err_info = try bad.get_err();
        std.debug.print(
            "payload carried with error {s}: \"{s}\"\n",
            .{ @errorName(err_info.tag), err_info.payload },
        );
    }

    // 3. Trying to call get_ok() on an error should fail with error.InvalidAccess
    if (bad.get_ok()) |unexpected_ok| {
        std.debug.print("bad.get_ok() unexpectedly gave {d}\n", .{unexpected_ok});
    } else |e| {
        std.debug.print(
            "bad.get_ok() failed as expected with error: {s}\n",
            .{@errorName(e)},
        );
    }

    // 4. Trying to call get_err() on an ok should fail with error.InvalidAccess
    if (good.get_err()) |unexpected_err| {
        _ = unexpected_err;
        std.debug.print("good.get_err() unexpectedly succeeded\n", .{});
    } else |e2| {
        std.debug.print(
            "good.get_err() failed as expected with error: {s}\n",
            .{@errorName(e2)},
        );
    }
}

// ---------------------------------------
// Tests: `zig build test`
// ---------------------------------------

test "ok variant basic behavior" {
    const good = ResultI32.ok(42);

    // get_ok() works
    try std.testing.expectEqual(@as(i32, 42), try good.get_ok());

    // get() behaves like `MyError!i32` and succeeds
    try std.testing.expectEqual(@as(i32, 42), try good.get());

    // get_err() should be InvalidAccess on an ok
    try std.testing.expectError(error.InvalidAccess, good.get_err());
}

test "err variant basic behavior" {
    const bad = ResultI32.err(MyError.NotFound, "file.txt");

    // get() should surface the MyError.NotFound tag
    try std.testing.expectError(MyError.NotFound, bad.get());

    // get_ok() should reject access
    try std.testing.expectError(error.InvalidAccess, bad.get_ok());

    // get_err() should succeed and carry both tag and payload
    const err_info = try bad.get_err();
    try std.testing.expectEqual(MyError.NotFound, err_info.tag);
    try std.testing.expectEqualStrings("file.txt", err_info.payload);
}

test "cross-check invalid access behavior symmetry" {
    const okv = ResultI32.ok(7);
    const errv = ResultI32.err(MyError.PermissionDenied, "nope");

    // okv: get_ok works, get_err fails
    try std.testing.expectEqual(@as(i32, 7), try okv.get_ok());
    try std.testing.expectError(error.InvalidAccess, okv.get_err());

    // errv: get_err works, get_ok fails
    const info = try errv.get_err();
    try std.testing.expectEqual(MyError.PermissionDenied, info.tag);
    try std.testing.expectEqualStrings("nope", info.payload);
    try std.testing.expectError(error.InvalidAccess, errv.get_ok());
}
