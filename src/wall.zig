pub const WallType = enum {
    Brick,
    Concrete,
    Net,
    Empty,
};

pub const Wall = struct {
    variant: WallType,
    position: @Vector(2, u32),

    pub fn init(position: [2]u32, variant: WallType) Wall {
        return Wall{ .variant = variant, .position = position };
    }

    pub fn isVisible(self: Wall) bool {
        return self != WallType.Empty;
    }

    pub fn setVariant(self: *Wall, variant: WallType) void {
        self.variant = variant;
    }
};
