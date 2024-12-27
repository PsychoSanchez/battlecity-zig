const std = @import("std");
const log = @import("./debug.zig").log;
const rl = @import("raylib");
const Game = @import("./game.zig").Game;
const Wall = @import("./wall.zig").Wall;
const WallType = @import("./wall.zig").WallType;
const spriteDb = @import("./sprite.db.zig");

// const Scene = struct {};
fn getCellSizeFromScreenSize(screenWidth: i32, screenHeight: i32, gridSize: u32) f32 {
    return @as(f32, @floatFromInt(@min(screenHeight, screenWidth))) / @as(f32, @floatFromInt(gridSize));
}

const GridScreenManager = struct {
    screenWidth: i32 = 800,
    screenHeight: i32 = 450,
    gridSize: u32 = 10,
    cellScreenSize: f32 = getCellSizeFromScreenSize(800, 450, 10),
    gridScreenOriginX: f32 = 0,
    gridScreenOriginY: f32 = 0,

    pub fn init() GridScreenManager {
        var manager = GridScreenManager{};

        manager.setGridSize(10);
        manager.setScreenSize(800, 450);

        return manager;
    }

    pub fn setGridSize(self: *GridScreenManager, gridSize: u32) void {
        self.gridSize = gridSize;
        self.updateScreenOrigin();
    }

    pub fn setScreenSize(self: *GridScreenManager, width: i32, height: i32) void {
        self.screenWidth = width;
        self.screenHeight = height;
        self.updateScreenOrigin();
    }

    pub fn getScreenWidth(self: GridScreenManager) i32 {
        return self.screenWidth;
    }

    fn updateScreenOrigin(self: *GridScreenManager) void {
        self.cellScreenSize = getCellSizeFromScreenSize(self.screenWidth, self.screenHeight, self.gridSize);
        const gridRenderSize = self.cellScreenSize * @as(f32, @floatFromInt(self.gridSize));
        self.gridScreenOriginX = (@as(f32, @floatFromInt(self.screenWidth)) - gridRenderSize) / 2.0;
        self.gridScreenOriginY = (@as(f32, @floatFromInt(self.screenHeight)) - gridRenderSize) / 2.0;
    }
};

pub fn main() anyerror!void {
    var gridScreenManager = GridScreenManager.init();

    const windowConfig = rl.ConfigFlags{ .window_resizable = true, .window_highdpi = true };

    log("Initializing window");
    std.debug.print("Setting window config flags: {}\n", .{windowConfig});

    rl.setConfigFlags(windowConfig);
    rl.setTargetFPS(300);

    log("Initializing memory allocator");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    log("Initializing window");
    rl.initWindow(gridScreenManager.screenWidth, gridScreenManager.screenHeight, "battlecity-zig");

    log("Initializing textures");
    // Load Textures
    const tankSprite = rl.Texture.init("resources/tanks.png");
    defer tankSprite.unload();

    log("Initializing obstacles");
    var obstacles = try ObstacleGenerator.init(10, 10, &allocator);
    defer obstacles.deinit();

    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        // const deltaTime = rl.getFrameTime();
        // const mousePosition = rl.getMousePosition();

        // Update key press states
        const keyState = rl.getKeyPressed();
        switch (keyState) {
            rl.KeyboardKey.space => {
                gridScreenManager.setGridSize(20);
                try obstacles.setGridSize(20);
                log("Space key is pressed");
            },
            rl.KeyboardKey.enter => {
                obstacles.setRngSeed(@intCast(rl.getRandomValue(0, 10000)));
                log("Enter key is pressed");
            },
            else => {},
        }

        // Update game state

        // Update window size
        if (rl.isWindowResized()) {
            log("Window resized");

            gridScreenManager.setScreenSize(rl.getScreenWidth(), rl.getScreenHeight());
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        // tankSprite.drawRec(0, 0, rl.Color.white);
        for (obstacles.walls) |row| {
            for (row) |cell| {
                // const cellSizeVector: @Vector(2, u32) = @splat(cellSize);
                // const screenCoords = cell.position * cellSizeVector;
                const spriteRect: ?[4]f32 = switch (cell.variant) {
                    WallType.Brick => spriteDb.BRICK_TILE,
                    WallType.Concrete => spriteDb.CONCRETE_TILE,
                    WallType.Net => spriteDb.NET_TILE,
                    else => null,
                };

                if (spriteRect) |rect| {
                    const originPosition = rl.Vector2.init(0.0, 0.0);
                    const sourceRectangle = rl.Rectangle.init(rect[0], rect[1], spriteDb.TILE_SIZE, spriteDb.TILE_SIZE);
                    const destX = gridScreenManager.gridScreenOriginX + @as(f32, @floatFromInt(cell.position[0])) * gridScreenManager.cellScreenSize;
                    const destY = gridScreenManager.gridScreenOriginY + @as(f32, @floatFromInt(cell.position[1])) * gridScreenManager.cellScreenSize;
                    const destRectangle = rl.Rectangle.init(destX, destY, gridScreenManager.cellScreenSize, gridScreenManager.cellScreenSize);

                    tankSprite.drawPro(sourceRectangle, destRectangle, originPosition, 0, rl.Color.white);
                }
            }
        }

        rl.drawFPS(0, 0);
        // var screenText: [64]u8 = undefined;
        // const written = try std.fmt.bufPrintZ(&screenText, "Mouse position: (\"{d} {d}\")", .{
        //     .x = mousePosition.x,
        //     .y = mousePosition.y,
        // });

        // // rl.drawText(@ptrCast(written.ptr), 190, 200, 20, rl.Color.light_gray);
        // rl.drawText(written[0.. :0], 190, 200, 20, rl.Color.light_gray);
    }

    // // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush();
}

const ObstacleGenerator = struct {
    walls: [][]Wall = undefined,
    rngSeed: u64 = 0,
    allocator: *const std.mem.Allocator,

    pub fn init(row_count: u8, column_count: u8, allocator: *const std.mem.Allocator) !ObstacleGenerator {
        var obstacles = ObstacleGenerator{ .allocator = allocator, .rngSeed = 0 };
        try obstacles.alloc(row_count, column_count);
        obstacles.generateObstacles();
        return obstacles;
    }

    pub fn alloc(self: *ObstacleGenerator, row_count: u8, column_count: u8) !void {
        self.walls = try self.allocator.alloc([]Wall, row_count);

        for (0..row_count) |y| {
            const row = try self.allocator.alloc(Wall, column_count);

            for (0..column_count) |x| {
                row[x] = Wall.init(.{ @intCast(x), @intCast(y) }, WallType.Empty);
            }

            self.walls[y] = row;
        }
    }

    pub fn setGridSize(self: *ObstacleGenerator, gridSize: u8) !void {
        self.deinit();
        try self.alloc(gridSize, gridSize);
        self.generateObstacles();
    }

    pub fn setRngSeed(self: *ObstacleGenerator, seed: u64) void {
        self.rngSeed = seed;
        self.generateObstacles();
    }

    pub fn generateObstacles(self: ObstacleGenerator) void {
        var rng = std.rand.DefaultPrng.init(self.rngSeed);

        for (self.walls, 0..) |row, x| {
            for (0..row.len) |y| {
                const newObstacle = switch (rng.next() % 6) {
                    0 | 1 => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.Brick),
                    2 => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.Concrete),
                    3 => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.Net),
                    else => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.Empty),
                };
                row[y] = newObstacle;
            }
        }

        const rowCount = self.walls.len;
        const colCount = self.walls[0].len;

        self.walls[0][0].setVariant(WallType.Empty);
        self.walls[rowCount - 1][0].setVariant(WallType.Empty);
        self.walls[0][colCount - 1].setVariant(WallType.Empty);
        self.walls[rowCount - 1][colCount - 1].setVariant(WallType.Empty);
    }

    pub fn deinit(self: ObstacleGenerator) void {
        for (self.walls) |wall| {
            self.allocator.free(wall);
        }
        self.allocator.free(self.walls);
    }
};

test "generateObstacles: Check that all corners are empty" {
    const obstacles = try ObstacleGenerator.init(10, 10, &std.testing.allocator);
    defer obstacles.deinit();

    try std.testing.expectEqual(obstacles.walls[0][0].variant, WallType.Empty);
    try std.testing.expectEqual(obstacles.walls[9][0].variant, WallType.Empty);
    try std.testing.expectEqual(obstacles.walls[0][9].variant, WallType.Empty);
    try std.testing.expectEqual(obstacles.walls[9][9].variant, WallType.Empty);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
