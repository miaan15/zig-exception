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
const MyError = error{ NotFound, PermissionDenied };
// result might be i32 if success; return MyError and message if error:
const ResultI32 = Exception(i32, MyError, []const u8);

pub fn foo(x: i32) ResultI32 {
    if (x < 0) {
        return ResultI32.err(MyError.PermissionDenied, "x was negative");
    }
    return ResultI32.ok(x * 2);
}

pub fn main() !void {
    const r = foo(-5);
    if (r.get()) |ok_val| {
        std.debug.print("Got success: {d}\n", .{ok_val});
    } else |err_tag| {
        std.debug.print("Got error tag: {s}\n", .{@errorName(err_tag)});
        const err_info = try r.get_err();
        std.debug.print("  payload: \"{s}\"\n", .{err_info.payload});
    }
}
```
