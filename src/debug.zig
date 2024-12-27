const std = @import("std");

pub fn log(message: []const u8) void {
    std.debug.print("LOG: {s}\n", .{message});
}
