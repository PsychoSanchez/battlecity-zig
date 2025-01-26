const Direction = @import("../core/grid.zig").Direction;

pub const Projectile = struct {
    position: [2][2]u32,
    direction: Direction,
    isAlive: bool = false,

    pub fn destroy(self: *Projectile) void {
        self.isAlive = false;
        self.direction = Direction.Down;
        self.position = .{ .{ 0, 0 }, .{ 0, 0 } };
    }
};
