pub const GAME_OVER_TEXTURE_PATH: []const u8 = "resources/gameover.png";
pub const TANKS_TEXTURE_PATH: []const u8 = "resources/tanks.png";

pub const TILE_SIZE: f32 = 16.0;
pub const SpriteId = enum {
    brick,
    concrete,
    net,
    tank1up,
    tank1down,
    tank1left,
    tank1right,
    armored_tank1up,
    armored_tank1right,
    armored_tank1down,
    armored_tank1left,
};
pub const TILES = &.{ &.{ 0.0 * TILE_SIZE, 0.0 * TILE_SIZE }, &.{ 1.0 * TILE_SIZE, 0.0 * TILE_SIZE }, &.{ 7.0 * TILE_SIZE, 3.0 * TILE_SIZE } };

pub fn getSprite(comptime tile: SpriteId) []const f32 {
    return comptime switch (tile) {
        .brick => &.{ 0.0 * TILE_SIZE, 0.0 * TILE_SIZE },
        .concrete => &.{ 1.0 * TILE_SIZE, 0.0 * TILE_SIZE },
        .net => &.{ 7.0 * TILE_SIZE, 3.0 * TILE_SIZE },
        .tank1up => &.{ 0.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .tank1down => &.{ 4.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .tank1left => &.{ 6.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .tank1right => &.{ 2.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        // TODO:
        .armored_tank1up => &.{ 0.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .armored_tank1down => &.{ 4.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .armored_tank1left => &.{ 6.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .armored_tank1right => &.{ 2.0 * TILE_SIZE, 1.0 * TILE_SIZE },
    };
}

pub fn getSpriteR(tile: SpriteId) []const f32 {
    return switch (tile) {
        .brick => &.{ 0.0 * TILE_SIZE, 0.0 * TILE_SIZE },
        .concrete => &.{ 1.0 * TILE_SIZE, 0.0 * TILE_SIZE },
        .net => &.{ 7.0 * TILE_SIZE, 3.0 * TILE_SIZE },
        .tank1up => &.{ 0.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .tank1down => &.{ 4.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .tank1left => &.{ 6.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .tank1right => &.{ 2.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        // TODO:
        .armored_tank1up => &.{ 0.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .armored_tank1down => &.{ 4.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .armored_tank1left => &.{ 6.0 * TILE_SIZE, 1.0 * TILE_SIZE },
        .armored_tank1right => &.{ 2.0 * TILE_SIZE, 1.0 * TILE_SIZE },
    };
}

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

pub const TANK_1_SPRITES = [8]SpriteId{
    SpriteId.tank1up,
    SpriteId.tank1right,
    SpriteId.tank1down,
    SpriteId.tank1left,
    SpriteId.armored_tank1up,
    SpriteId.armored_tank1right,
    SpriteId.armored_tank1down,
    SpriteId.armored_tank1left,
};

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
