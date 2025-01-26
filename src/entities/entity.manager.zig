const SpriteId = @import("../sprite.db.zig").SpriteId;

const Projectile = @import("../entities/projectile.zig").Projectile;
const Animation = @import("../entities/animation.zig").Animation;

pub fn spawnProjectile(projectiles: *const []Projectile, projectile: Projectile) void {
    for (projectiles.*) |*p| {
        if (!p.isAlive) {
            p.* = projectile;

            break;
        }
    }
}

pub fn spawnAnimation(animations: *const []Animation, animation: Animation) void {
    for (animations.*) |*p| {
        if (!p.isPlaying) {
            p.* = animation;

            break;
        }
    }
}

const EXPLOSION_ANIMATION: [3]SpriteId = .{ SpriteId.explosion_frame_1, SpriteId.explosion_frame_2, SpriteId.explosion_frame_3 };
pub fn spawnExplosionAnimation(animations: *const []Animation, position: [2]u32) void {
    const framePtr: *const [3]SpriteId = &EXPLOSION_ANIMATION;
    const slice: []const SpriteId = framePtr[0..];

    spawnAnimation(animations, Animation{
        .current = 0,
        .frames = &slice,
        .isPlaying = true,
        .position = position,
    });
}

const SPAWN_ANIMATION: [3]SpriteId = .{ SpriteId.spawn_frame_1, SpriteId.spawn_frame_2, SpriteId.spawn_frame_3 };
pub fn spawnSpawnAnimation(animations: *const []Animation, position: [2]u32) void {
    spawnAnimation(animations, Animation{
        .current = 0,
        .frames = &SPAWN_ANIMATION,
        .isPlaying = true,
        .position = position,
    });
}
