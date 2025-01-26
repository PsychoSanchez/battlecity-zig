pub const Direction = enum {
    Up,
    Right,
    Down,
    Left,
};

pub fn getPositionFromDirection(position: *[2]u32, direction: Direction, maxBoundary: usize) ?[2]u32 {
    const x = position[0];
    const y = position[1];

    return switch (direction) {
        .Up => if (y == 0) null else .{ x, y - 1 },
        .Down => if (y == maxBoundary - 1) null else .{ x, y + 1 },
        .Left => if (x == 0) null else .{ x - 1, y },
        .Right => if (x == maxBoundary - 1) null else .{ x + 1, y },
    };
}

fn getCellSizeFromScreenSize(screenWidth: i32, screenHeight: i32, gridSize: u32) f32 {
    return @as(f32, @floatFromInt(@min(screenHeight, screenWidth))) / @as(f32, @floatFromInt(gridSize));
}

pub const GridScreenManager = struct {
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

    pub fn toScreenCoords(self: GridScreenManager, position: *const [2]f32) [2]f32 {
        const destX = self.gridScreenOriginX + position[0] * self.cellScreenSize;
        const destY = self.gridScreenOriginY + position[1] * self.cellScreenSize;

        return .{ destX, destY };
    }
};
