# zig-exception

A small generic result/exception wrapper for [Zig](https://ziglang.org).  
It allows you to wrap a success-value type and an error tag + payload, similar to `std::exception` in C++.

### Features

- Define `Exception(T, ETag, EPayload)`:
  - `T` = the success type  
  - `ETag` = an error tag type (e.g. an `error{…}` enum)  
  - `EPayload` = an arbitrary payload type carried along with errors  
- Construct:
  - `.ok(value)` → success  
  - `.err(tag, payload)` → error  
- Accessors:
  - `.get()` → returns `ETag!T` (i.e. either success value or error tag)  
  - `.get_ok()` → returns `!T` (error if trying to get ok from an error)  
  - `.get_err()` → returns `!E` (where `E` contains tag + payload; error if trying on an ok)  

### Demo & Test

```bash
zig build run
zig build test
```

### Example

```zig
const std = @import("std");
const Exception = @import("exception").Exception;

// define your specific alias:
const MyError = error{ Zero, Negetive };

// result might be i32 if success; return MyError and message if error:
const ResultI32 = Exception(i32, MyError, []const u8);

pub fn foo(x: i32) ResultI32 {
    if (x < 0) {
        return ResultI32.err(MyError.Negetive, "x was negative");
    }
    if (x == 0) {
        return ResultI32.err(MyError.Zero, "x was zero");
    }
    return ResultI32.ok(x * 2);
}

pub fn main() !void {
    // expect error
    const r1 = foo(-5);
    std.debug.print("Case: x = -5\n", .{});
    if (r1.get()) |ok_val| {
        std.debug.print("Success value (x * 2): {d}\n", .{ok_val});
    } else |err_tag| {
        std.debug.print("Error tag: {s}\n", .{@errorName(err_tag)});
        const err_info = try r1.get_err();
        std.debug.print("  payload: \"{s}\"\n", .{err_info.payload});
    }

    // expect success
    const r2 = foo(10);
    std.debug.print("\nCase: x = 10\n", .{});

    const val = r2.get() catch |e| {
        std.debug.print("Caught error from .get(): {s}\n", .{@errorName(e)});
        return;
    };
    std.debug.print("Success value (x * 2): {d}\n", .{val});
}
```
```
Case: x = -5
Error tag: Negetive
  payload: "x was negative"

Case: x = 10
Success value (x * 2): 20
```
