const rl = @import("raylib");

const LookDirection = enum {
    Up,
    Down,
    Left,
    Right,
    fn positionFrom() !void {}
};

pub const Player = struct {
    id: u32,

    // [current, previous]
    // position: [[i32; 2]; 2],
    position: [2][2]i32,

    lives: u32,
    health: u32,
    armor: u32,
    max_health: u32,
    max_armor: u32,

    kills: u32,

    is_alive: bool,
    spawn: [2]i32,
    spawn_health: u32,
    spawn_armor: u32,

    last_shot_dt: f64,
    shot_interval: f64,

    movement_controls: [4]rl.KeyboardKey,
    movement_controls_state: [4]bool,
    fire_control: rl.KeyboardKey,
    fire_control_state: bool,

    direction: LookDirection,
    spawn_direction: LookDirection,

    tiles: [8][4]f64,
};
