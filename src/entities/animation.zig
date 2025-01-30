const SpriteId = @import("../sprite.db.zig").SpriteId;

const EXPLOSION_ANIMATION: [3]SpriteId = .{ SpriteId.explosion_frame_1, SpriteId.explosion_frame_2, SpriteId.explosion_frame_3 };
const SPAWN_ANIMATION: [3]SpriteId = .{ SpriteId.spawn_frame_1, SpriteId.spawn_frame_2, SpriteId.spawn_frame_3 };

pub const Animation = struct {
    position: [2]u32,
    frames: *const []const SpriteId,
    current: usize = 0,
    isPlaying: bool = true,

    pub fn default() Animation {
        return Animation{
            .position = [2]u32{ 0, 0 },
            .frames = null,
            .current = 0,
            .isPlaying = false,
        };
    }

    pub fn explosion(position: [2]u32) Animation {
        const framePtr: *const [3]SpriteId = &EXPLOSION_ANIMATION;
        const slice: []const SpriteId = framePtr[0..];

        return Animation{
            .position = position,
            .frames = &slice,
            .current = 0,
            .isPlaying = true,
        };
    }

    pub fn spawn(position: [2]u32) Animation {
        const framePtr: *const [3]SpriteId = &SPAWN_ANIMATION;
        const slice: []const SpriteId = framePtr[0..];

        return Animation{
            .position = position,
            .frames = &slice,
            .current = 0,
            .isPlaying = false,
        };
    }
};
