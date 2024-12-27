const Player = @import("./player.zig").Player;
const Wall = @import("./wall.zig").Wall;

pub const Game = struct {
    column_count: u8,
    row_count: u8,
    players: []Player,
    walls: [][]Wall,
    // pickups: Vec<Pickup>,
    // pickup_spawn_systems: [PickupSpawnSystem; 2],
    max_pickups: usize,
    // bullets: Vec<Projectile>,
    // animations: Vec<Animation>,
    accumulated_time: f64,
    last_update: f64,
    update_interval: f64,
    // render: GameRender,
};
