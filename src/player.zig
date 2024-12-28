const std = @import("std");
const rl = @import("raylib");
const log = @import("./debug.zig").log;

pub const LookDirection = enum {
    Up,
    Right,
    Down,
    Left,

    fn positionFrom(self: LookDirection, position: []const i32) [2]i32 {
        const x = position[0];
        const y = position[1];

        return switch (self) {
            .Up => .{ x, y - 1 },
            .Down => .{ x, y + 1 },
            .Left => .{ x - 1, y },
            .Right => .{ x + 1, y },
        };
    }
};

pub const Player = struct {
    id: u32,

    // [current, previous]
    position: [2][2]i32 = .{ .{ 0, 0 }, .{ 0, 0 } },
    lookDirection: LookDirection,

    lives: u32 = 3,
    health: u32 = 3,
    armor: u32 = 0,
    maxHealth: u32 = 3,
    maxArmor: u32 = 3,

    kills: u32 = 0,

    isAlive: bool = true,

    dtSinceLastShot: f64 = 0.0,
    shotInterval: f64 = 0.5,

    movementKeys: [4]rl.KeyboardKey,
    movementKeysDownState: [4]bool = .{ false, false, false, false },
    fireKey: rl.KeyboardKey,
    isFireKeyDown: bool = false,

    spawnPosition: [2]i32 = .{ 0, 0 },
    spawnHealth: u32 = 3,
    spawnArmor: u32 = 3,
    spawnDirection: LookDirection,

    tiles: [8]([]const f32),

    pub fn getSprite(self: Player) []const f32 {
        const shift: u8 = if (self.armor > 0) 4 else 0;

        return switch (self.lookDirection) {
            .Up => self.tiles[0 + shift],
            .Right => self.tiles[1 + shift],
            .Down => self.tiles[2 + shift],
            .Left => self.tiles[3 + shift],
        };
    }

    pub fn onUpdate(self: *Player, dt: f32) void {
        self.dtSinceLastShot += dt;
        self.updateKeyState();
        // self.direction = self.movement_controls
    }

    pub fn isReloading(self: Player) bool {
        return self.dtSinceLastShot < self.shotInterval;
    }

    pub fn onGameTick(self: *Player) void {
        // Shoot
        if (self.isFireKeyDown and !self.isReloading()) {
            log("shots fired");
            self.dtSinceLastShot = 0.0;
        }

        var pressedKeyIndex: ?usize = null;
        for (self.movementKeysDownState, 0..) |keyState, index| {
            if (keyState) {
                pressedKeyIndex = index;
                break;
            }
        }

        const currentPosition = self.position[0];
        if (pressedKeyIndex) |index| {
            self.lookDirection = @as(LookDirection, @enumFromInt(index));
            const newPosition = self.lookDirection.positionFrom(&currentPosition);
            self.position = .{ newPosition, currentPosition };
        } else {
            self.position = .{ currentPosition, currentPosition };
        }
    }

    pub fn updateKeyState(self: *Player) void {
        for (self.movementKeys, 0..) |key, index| {
            self.movementKeysDownState[index] = rl.isKeyDown(key);
        }

        self.isFireKeyDown = rl.isKeyDown(self.fireKey);
    }
};
