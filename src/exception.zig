pub fn Exception(comptime T: type, comptime ETag: type, comptime EPayload: type) type {
    const E = struct {
        tag: ETag,
        payload: EPayload,
    };
    return struct {
        data: union(enum) { ok: T, err: E },

        pub fn ok(v: T) Exception(T, ETag, EPayload) {
            return .{ .data = .{ .ok = v } };
        }
        pub fn err(t: ETag, v: EPayload) Exception(T, ETag, EPayload) {
            return .{ .data = .{ .err = .{ .tag = t, .payload = v } } };
        }

        pub fn get(self: *const Exception(T, ETag, EPayload)) ETag!T {
            return switch (self.data) {
                .ok => |x| return x,
                .err => |x| return x.tag,
            };
        }
        pub fn get_ok(self: *const Exception(T, ETag, EPayload)) !T {
            if (self.data != .ok) return error.InvalidAccess;
            return self.data.ok;
        }
        pub fn get_err(self: *const Exception(T, ETag, EPayload)) !E {
            if (self.data != .err) return error.InvalidAccess;
            return self.data.err;
        }
    };
}
