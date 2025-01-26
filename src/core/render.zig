const RL = @import("raylib");
const GridScreenManager = @import("./grid.zig").GridScreenManager;

pub const RenderPositionType = enum(u8) { static, dynamic };
pub const RenderPosition = union(RenderPositionType) {
    static: *const [2]u32,
    dynamic: *const [2]f32,
};
const RectBound = [4]f32;
pub const RenderEntity = struct {
    position: RenderPosition,
    sprite: *const RectBound,
};

pub fn renderSprite(texture: *const RL.Texture, screenManager: *const GridScreenManager, args: *const RenderEntity) void {
    const originPosition = RL.Vector2.init(0.0, 0.0);
    const sourceRectangle = RL.Rectangle.init(args.sprite.ptr[0], args.sprite.ptr[1], args.sprite.ptr[2], args.sprite.ptr[3]);
    const dest = switch (args.position) {
        .dynamic => |position| screenManager.toScreenCoords(position),
        .static => |position| screenManager.toScreenCoords(&.{
            @as(f32, @floatFromInt(position[0])),
            @as(f32, @floatFromInt(position[1])),
        }),
    };
    const destRectangle = RL.Rectangle.init(dest[0], dest[1], screenManager.cellScreenSize, screenManager.cellScreenSize);

    texture.drawPro(sourceRectangle, destRectangle, originPosition, 0, RL.Color.white);
}
