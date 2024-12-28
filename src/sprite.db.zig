pub const GAME_OVER_TEXTURE_PATH: []const u8 = "resources/gameover.png";
pub const TANKS_TEXTURE_PATH: []const u8 = "resources/tanks.png";

pub const TILE_SIZE: f32 = 16.0;
pub const BRICK_TILE: []const f32 = &.{ 0.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const CONCRETE_TILE: []const f32 = &.{ 1.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const ARMOR_PICKUP_TILE: []const f32 = &.{ 2.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const SHELL_UP_TILE: []const f32 = &.{ 3.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const SHELL_RIGHT_TILE: []const f32 = &.{ 4.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const SHELL_DOWN_TILE: []const f32 = &.{ 5.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const SHELL_LEFT_TILE: []const f32 = &.{ 6.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const HEALTH_PICKUP_TILE: []const f32 = &.{ 7.0 * TILE_SIZE, 0.0 * TILE_SIZE };
pub const TANK_1_TILE_UP: []const f32 = &.{ 0.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_2_TILE_UP: []const f32 = &.{ 1.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_1_TILE_RIGHT: []const f32 = &.{ 2.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_2_TILE_RIGHT: []const f32 = &.{ 3.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_1_TILE_DOWN: []const f32 = &.{ 4.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_2_TILE_DOWN: []const f32 = &.{ 5.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_1_TILE_LEFT: []const f32 = &.{ 6.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_2_TILE_LEFT: []const f32 = &.{ 7.0 * TILE_SIZE, 1.0 * TILE_SIZE };
pub const TANK_3_TILE_UP: []const f32 = &.{ 0.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const TANK_4_TILE_UP: []const f32 = &.{ 1.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const TANK_3_TILE_RIGHT: []const f32 = &.{ 2.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const TANK_4_TILE_RIGHT: []const f32 = &.{ 3.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const TANK_3_TILE_DOWN: []const f32 = &.{ 4.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const TANK_4_TILE_DOWN: []const f32 = &.{ 5.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const TANK_3_TILE_LEFT: []const f32 = &.{ 6.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const TANK_4_TILE_LEFT: []const f32 = &.{ 7.0 * TILE_SIZE, 2.0 * TILE_SIZE };
pub const EXPLOSION_FRAME_1_TILE: []const f32 = &.{ 0.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const EXPLOSION_FRAME_2_TILE: []const f32 = &.{ 1.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const EXPLOSION_FRAME_3_TILE: []const f32 = &.{ 2.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const EMPTY_FRAME_TILE: []const f32 = &.{ 3.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const SPAWN_FRAME_1_TILE: []const f32 = &.{ 4.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const SPAWN_FRAME_2_TILE: []const f32 = &.{ 5.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const SPAWN_FRAME_3_TILE: []const f32 = &.{ 6.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const NET_TILE: []const f32 = &.{ 7.0 * TILE_SIZE, 3.0 * TILE_SIZE };
pub const ARMORED_TANK_1_TILE_UP: []const f32 = &.{ 0.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_2_TILE_UP: []const f32 = &.{ 1.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_1_TILE_RIGHT: []const f32 = &.{ 2.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_2_TILE_RIGHT: []const f32 = &.{ 3.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_1_TILE_DOWN: []const f32 = &.{ 4.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_2_TILE_DOWN: []const f32 = &.{ 5.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_1_TILE_LEFT: []const f32 = &.{ 6.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_2_TILE_LEFT: []const f32 = &.{ 7.0 * TILE_SIZE, 4.0 * TILE_SIZE };
pub const ARMORED_TANK_3_TILE_UP: []const f32 = &.{ 0.0 * TILE_SIZE, 5.0 * TILE_SIZE };
pub const ARMORED_TANK_4_TILE_UP: []const f32 = &.{ 1.0 * TILE_SIZE, 5.0 * TILE_SIZE };
pub const ARMORED_TANK_3_TILE_RIGHT: []const f32 = &.{ 2.0 * TILE_SIZE, 5.0 * TILE_SIZE };
pub const ARMORED_TANK_4_TILE_RIGHT: []const f32 = &.{ 3.0 * TILE_SIZE, 5.0 * TILE_SIZE };
pub const ARMORED_TANK_3_TILE_DOWN: []const f32 = &.{ 4.0 * TILE_SIZE, 5.0 * TILE_SIZE };
pub const ARMORED_TANK_4_TILE_DOWN: []const f32 = &.{ 5.0 * TILE_SIZE, 5.0 * TILE_SIZE };
pub const ARMORED_TANK_3_TILE_LEFT: []const f32 = &.{ 6.0 * TILE_SIZE, 5.0 * TILE_SIZE };
pub const ARMORED_TANK_4_TILE_LEFT: []const f32 = &.{ 7.0 * TILE_SIZE, 5.0 * TILE_SIZE };

pub const TANK_1_TILES = [8]([]const f32){
    TANK_1_TILE_UP,
    TANK_1_TILE_RIGHT,
    TANK_1_TILE_DOWN,
    TANK_1_TILE_LEFT,
    ARMORED_TANK_1_TILE_UP,
    ARMORED_TANK_1_TILE_RIGHT,
    ARMORED_TANK_1_TILE_DOWN,
    ARMORED_TANK_1_TILE_LEFT,
};
pub const TANK_2_TILES = [8]([]const f32){
    TANK_2_TILE_UP,
    TANK_2_TILE_RIGHT,
    TANK_2_TILE_DOWN,
    TANK_2_TILE_LEFT,
    ARMORED_TANK_2_TILE_UP,
    ARMORED_TANK_2_TILE_RIGHT,
    ARMORED_TANK_2_TILE_DOWN,
    ARMORED_TANK_2_TILE_LEFT,
};
pub const TANK_3_TILES = [8]([]const f32){
    TANK_3_TILE_UP,
    TANK_3_TILE_RIGHT,
    TANK_3_TILE_DOWN,
    TANK_3_TILE_LEFT,
    ARMORED_TANK_3_TILE_UP,
    ARMORED_TANK_3_TILE_RIGHT,
    ARMORED_TANK_3_TILE_DOWN,
    ARMORED_TANK_3_TILE_LEFT,
};
pub const TANK_4_TILES = [8]([]const f32){
    TANK_4_TILE_UP,
    TANK_4_TILE_RIGHT,
    TANK_4_TILE_DOWN,
    TANK_4_TILE_LEFT,
    ARMORED_TANK_4_TILE_UP,
    ARMORED_TANK_4_TILE_RIGHT,
    ARMORED_TANK_4_TILE_DOWN,
    ARMORED_TANK_4_TILE_LEFT,
};
pub const EXPLOSION_FRAMES = [3]([]const f32){
    EXPLOSION_FRAME_1_TILE,
    EXPLOSION_FRAME_2_TILE,
    EXPLOSION_FRAME_3_TILE,
};

pub const SPAWN_FRAMES =
    [3]([]const f32){ SPAWN_FRAME_1_TILE, SPAWN_FRAME_2_TILE, SPAWN_FRAME_3_TILE };
