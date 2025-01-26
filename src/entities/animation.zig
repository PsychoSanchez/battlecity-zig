const SpriteId = @import("../sprite.db.zig").SpriteId;

pub const Animation = struct { position: [2]u32, frames: *const []const SpriteId, current: usize = 0, isPlaying: bool = false };
