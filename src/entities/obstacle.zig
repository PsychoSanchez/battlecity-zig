const std = @import("std");

pub const ObstacleVariant = enum(u8) { brick, concrete, net };
pub const Brick = struct {
    health: u32,
};
pub const Concrete = struct {
    health: u32,
};
pub const Net = struct {};
pub const Obstacle = struct {
    position: [2]u32,
    variant: ObstacleVariant,
};

pub const ObstacleGridManager = struct {
    obstacles: [][]?Obstacle = undefined,
    rngSeed: u64 = 0,
    allocator: *const std.mem.Allocator,

    pub fn init(row_count: u32, column_count: u32, allocator: *const std.mem.Allocator) !ObstacleGridManager {
        var obstacles = ObstacleGridManager{ .allocator = allocator, .rngSeed = 0 };
        try obstacles.alloc(row_count, column_count);
        return obstacles;
    }

    pub fn alloc(self: *ObstacleGridManager, row_count: u32, column_count: u32) !void {
        self.obstacles = try self.allocator.alloc([]?Obstacle, row_count);

        for (0..row_count) |index| {
            const row = try self.allocator.alloc(?Obstacle, column_count);
            @memset(row, null);
            self.obstacles[index] = row;
        }
    }

    pub fn setGridSize(self: *ObstacleGridManager, gridSize: u32) !void {
        self.deinit();
        try self.alloc(gridSize, gridSize);
        self.generateObstacles();
    }

    pub fn setRngSeed(self: *ObstacleGridManager, seed: u64) void {
        self.rngSeed = seed;
        self.generateObstacles();
    }

    pub fn generateObstacles(self: ObstacleGridManager) void {
        var rng = std.rand.DefaultPrng.init(self.rngSeed);

        for (self.obstacles, 0..) |row, x| {
            for (0..row.len) |y| {
                const newObstacle = switch (rng.next() % 6) {
                    0, 1 => Obstacle{ .position = .{ @intCast(x), @intCast(y) }, .variant = ObstacleVariant.brick },
                    2 => Obstacle{ .position = .{ @intCast(x), @intCast(y) }, .variant = ObstacleVariant.concrete },
                    3 => Obstacle{ .position = .{ @intCast(x), @intCast(y) }, .variant = ObstacleVariant.net },
                    else => null,
                };
                row[y] = newObstacle;
            }
        }

        const rowCount = self.obstacles.len;
        const colCount = self.obstacles[0].len;

        self.obstacles[0][0] = null;
        self.obstacles[rowCount - 1][0] = null;
        self.obstacles[0][colCount - 1] = null;
        self.obstacles[rowCount - 1][colCount - 1] = null;
    }

    pub fn deinit(self: ObstacleGridManager) void {
        for (self.obstacles) |wall| {
            self.allocator.free(wall);
        }
        self.allocator.free(self.obstacles);
    }

    pub fn setObstacle(self: *ObstacleGridManager, obstacle: ?Obstacle, position: [2]u32) void {
        self.obstacles[position[0]][position[1]] = obstacle;
    }
};

test "Allocates null memory" {
    const obstacles = try ObstacleGridManager.init(10, 10, &std.testing.allocator);
    defer obstacles.deinit();

    for (0..10) |x| {
        for (0..10) |y| {
            try std.testing.expectEqual(obstacles.obstacles[x][y], null);
        }
    }
}

test "Check that all corners are empty" {
    var obstacles = try ObstacleGridManager.init(10, 10, &std.testing.allocator);
    obstacles.generateObstacles();
    defer obstacles.deinit();

    try std.testing.expectEqual(obstacles.obstacles[0][0], null);
    try std.testing.expectEqual(obstacles.obstacles[9][0], null);
    try std.testing.expectEqual(obstacles.obstacles[0][9], null);
    try std.testing.expectEqual(obstacles.obstacles[9][9], null);
}
