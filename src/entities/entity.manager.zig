const std = @import("std");
const SpriteId = @import("../sprite.db.zig").SpriteId;

const Player = @import("../entities/player.zig").Player;
const Projectile = @import("../entities/projectile.zig").Projectile;
const Animation = @import("../entities/animation.zig").Animation;
const Pickup = @import("../entities/pickup.zig").Pickup;

pub const EntityType = enum(u8) { player, pickup, animation, projectile };

const EXPLOSION_ANIMATION: [3]SpriteId = .{ SpriteId.explosion_frame_1, SpriteId.explosion_frame_2, SpriteId.explosion_frame_3 };
const SPAWN_ANIMATION: [3]SpriteId = .{ SpriteId.spawn_frame_1, SpriteId.spawn_frame_2, SpriteId.spawn_frame_3 };
pub const EntityManager = struct {
    allocator: std.mem.Allocator,
    projectiles: std.ArrayList(Projectile),
    players: std.ArrayList(Player),
    pickups: std.ArrayList(Pickup),
    animations: std.ArrayList(Animation),
    // obstacles: std.ArrayList(Obstacle),

    pub fn init(
        allocator: std.mem.Allocator,
        maxProjectiles: usize,
        maxPlayers: usize,
        maxAnimations: usize,
        maxPickups: usize,
    ) !EntityManager {
        return EntityManager{
            .allocator = allocator,
            .projectiles = try std.ArrayList(Projectile).initCapacity(allocator, maxProjectiles),
            .players = try std.ArrayList(Player).initCapacity(allocator, maxPlayers),
            .animations = try std.ArrayList(Animation).initCapacity(allocator, maxAnimations),
            .pickups = try std.ArrayList(Pickup).initCapacity(allocator, maxPickups),
        };
    }

    pub fn deinit(self: *EntityManager) void {
        self.projectiles.deinit();
        self.players.deinit();
        self.animations.deinit();
        self.pickups.deinit();
    }

    const SpawnEntityArg = union(EntityType) { player: Player, pickup: Pickup, animation: Animation, projectile: Projectile };
    pub fn spawn(self: *EntityManager, arg: SpawnEntityArg) !void {
        try switch (arg) {
            .player => |player| self.players.append(player),
            .pickup => |pickup| self.pickups.append(pickup),
            .animation => |animation| self.animations.append(animation),
            .projectile => |projectile| self.projectiles.append(projectile),
        };
    }

    const DestroyEntityArg = struct { entity: EntityType, index: usize };
    pub fn destroy(self: *EntityManager, arg: DestroyEntityArg) void {
        switch (arg.entity) {
            .player => {
                _ = self.players.swapRemove(arg.index);
            },
            .pickup => {
                _ = self.pickups.swapRemove(arg.index);
            },
            .animation => {
                _ = self.animations.swapRemove(arg.index);
            },
            .projectile => {
                _ = self.projectiles.swapRemove(arg.index);
            },
        }
    }

    const EntityLookupUnionType = enum(u8) { player, pickup, projectile };
    const EntityLookupResult = union(EntityLookupUnionType) { player: *Player, pickup: *Pickup, projectile: *Projectile };
    pub fn getEntitiesAtPosition(self: EntityManager, position: [2]u32) std.ArrayList(EntityLookupResult) {
        var entities = std.ArrayList(EntityLookupResult).init(self.allocator);

        for (self.players.items) |*player| {
            if (std.mem.eql(u32, &player.position[0], &position)) {
                _ = entities.append(.{ .player = player }) catch {};
            }
        }

        for (self.pickups.items) |*pickup| {
            if (std.mem.eql(u32, &pickup.position, &position)) {
                _ = entities.append(.{ .pickup = pickup }) catch {};
            }
        }

        for (self.projectiles.items) |*projectile| {
            if (std.mem.eql(u32, &projectile.position[0], &position)) {
                _ = entities.append(.{ .projectile = projectile }) catch {};
            }
        }

        return entities;
    }

    pub fn getEntityFromMovementHistory(self: EntityManager, position: [2][2]u32) std.ArrayList(EntityLookupResult) {
        var entities = std.ArrayList(EntityLookupResult).init(self.allocator);

        for (self.players.items) |*player| {
            if (std.mem.eql(u32, &player.position[0], &position[0]) and std.mem.eql(u32, &player.position[1], &position[1])) {
                _ = entities.append(.{ .player = player }) catch {};
            }
        }

        for (self.projectiles.items) |*projectile| {
            if (std.mem.eql(u32, &projectile.position[0], &position[0]) and std.mem.eql(u32, &projectile.position[1], &position[1])) {
                _ = entities.append(.{ .projectile = projectile }) catch {};
            }
        }

        return entities;
    }

    // Move to the Animation or somewhere else to create static constructor presets
    pub fn spawnExplosionAnimation(self: *EntityManager, position: [2]u32) void {
        const framePtr: *const [3]SpriteId = &EXPLOSION_ANIMATION;
        const slice: []const SpriteId = framePtr[0..];

        spawn(self, .{ .animation = Animation{
            .frames = &slice,
            .position = position,
        } }) catch |err| {
            switch (err) {
                else => {},
            }
        };
    }

    pub fn spawnSpawnAnimation(self: *EntityManager, position: [2]u32) void {
        const framePtr: *const [3]SpriteId = &SPAWN_ANIMATION;
        const slice: []const SpriteId = framePtr[0..];

        spawn(self, .{ .animation = Animation{
            .frames = &slice,
            .position = position,
        } }) catch |err| {
            switch (err) {
                else => {},
            }
        };
    }
};
