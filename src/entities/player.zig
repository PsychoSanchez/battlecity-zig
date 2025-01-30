const rl = @import("raylib");

const SpriteId = @import("../sprite.db.zig").SpriteId;

const Direction = @import("../core/grid.zig").Direction;
const KeyboardControl = @import("../core/controls.zig").KeyboardControl;

pub const Player = struct {
    id: u32,

    isAiControlled: bool = false,

    // [current, previous]
    position: [2][2]u32 = .{ .{ 0, 0 }, .{ 0, 0 } },
    direction: Direction,

    lives: u32 = 3,
    health: u32 = 3,
    armor: u32 = 0,
    maxHealth: u32 = 3,
    maxArmor: u32 = 3,

    kills: u32 = 0,

    isAlive: bool = true,

    dtSinceLastShot: f64 = 0.0,
    shotInterval: f64 = 0.5,

    spawnPosition: [2]i32 = .{ 0, 0 },
    spawnHealth: u32 = 3,
    spawnArmor: u32 = 3,
    spawnDirection: Direction,

    tiles: [8]SpriteId,

    movementControls: [4]KeyboardControl,
    fireControl: KeyboardControl,

    pub fn getSprite(self: Player) SpriteId {
        const shift: u8 = if (self.armor > 0) 4 else 0;

        return switch (self.direction) {
            .Up => self.tiles[0 + shift],
            .Right => self.tiles[1 + shift],
            .Down => self.tiles[2 + shift],
            .Left => self.tiles[3 + shift],
        };
    }

    pub fn updateControls(self: *Player) void {
        for (&self.movementControls) |*control| {
            control.update();
        }

        self.fireControl.update();
    }

    pub fn getPressedDirection(self: Player) ?Direction {
        if (self.isAiControlled) {
            return self.direction;
        }

        var activeControl: ?KeyboardControl = null;
        var activeIndex: ?usize = null;

        for (self.movementControls, 0..) |control, index| {
            if (control.isKeyDown and (activeControl == null or activeControl.?.lastActivatedAt < control.lastActivatedAt)) {
                activeControl = control;
                activeIndex = index;
            }
        }

        if (activeIndex) |index| {
            return switch (index) {
                0 => Direction.Up,
                1 => Direction.Right,
                2 => Direction.Down,
                3 => Direction.Left,
                else => null,
            };
        } else {
            return null;
        }
    }
};
