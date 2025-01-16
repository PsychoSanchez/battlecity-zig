const std = @import("std");
const log = @import("./debug.zig").log;
const RL = @import("raylib");
// const Player = @import("./player.zig").Player;
// const LookDirection = @import("./player.zig").LookDirection;
// const Game = @import("./game.zig").Game;
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

    pub fn toScreenCoords(self: GridScreenManager, position: *const [2]f32) [2]f32 {
        const destX = self.gridScreenOriginX + position[0] * self.cellScreenSize;
        const destY = self.gridScreenOriginY + position[1] * self.cellScreenSize;

        return .{ destX, destY };
    }
};

const Direction = enum {
    Up,
    Right,
    Down,
    Left,
};

const ObstacleVariant = enum { brick, concrete, net };
const Brick = struct {
    health: u32,
};
const Concrete = struct {
    health: u32,
};
const Net = struct {};
const Obstacle = struct { position: [2]u32, variant: ObstacleVariant };

const HealthPickup = struct {
    amount: u32,
};
const ArmorPickup = struct { amount: u32 };
const PickupVariantType = enum { health, armor };
const PickupVariant = union(PickupVariantType) { health: HealthPickup, armor: ArmorPickup };
const Pickup = struct { position: [2]u32, variant: PickupVariant };

const Animation = struct { position: [2]u32, frames: [][]const f32, current: usize = 0, isPlaying: bool = false };

const KeyboardControl = struct {
    key: RL.KeyboardKey,
    isKeyDown: bool = false,
    lastActivatedAt: i64 = 0,

    pub fn update(self: *KeyboardControl) void {
        const isKeyDown = RL.isKeyDown(self.key);
        if (isKeyDown and !self.isKeyDown) {
            self.lastActivatedAt = std.time.milliTimestamp();
        }

        self.isKeyDown = isKeyDown;
    }
};

const Player = struct {
    isAlive: bool,
    position: [2][2]u32,
    direction: Direction,
    armor: u8 = 0,
    movementControls: [4]KeyboardControl,
    fireControl: KeyboardControl,

    pub fn getSprite(self: Player) spriteDb.SpriteId {
        const shift: u8 = if (self.armor > 0) 4 else 0;
        const sprites = spriteDb.TANK_1_SPRITES;

        return switch (self.direction) {
            .Up => sprites[0 + shift],
            .Right => sprites[1 + shift],
            .Down => sprites[2 + shift],
            .Left => sprites[3 + shift],
        };
    }

    pub fn updateControls(self: *Player) void {
        for (&self.movementControls) |*control| {
            control.update();
        }

        self.fireControl.update();
    }

    pub fn getPressedDirection(self: Player) ?Direction {
        var activeControl: ?KeyboardControl = null;
        var activeIndex: ?usize = null;

        for (self.movementControls, 0..) |control, index| {
            if (control.isKeyDown and (activeControl == null or activeControl.?.lastActivatedAt < control.lastActivatedAt)) {
                activeControl = control;
                activeIndex = index;
            }
        }

        if (activeIndex) |index| {
            return switch (index) {
                0 => Direction.Up,
                1 => Direction.Right,
                2 => Direction.Down,
                3 => Direction.Left,
                else => null,
            };
        } else {
            return null;
        }
    }
};

const Projectile = struct {
    position: [2][2]u32,
    direction: Direction,
    isAlive: bool = false,

    pub fn destroy(self: *Projectile) void {
        self.isAlive = false;
        self.direction = Direction.Down;
        self.position = .{ .{ 0, 0 }, .{ 0, 0 } };
    }
};

const EntityType = enum { obstacle, pickup, player, animation, projectile };
const Entity = union(EntityType) {
    obstacle: Obstacle,
    pickup: Pickup,
    player: Player,
    animation: Animation,
    projectile: Projectile,
};

const EntityLookupUnionType = enum(u8) { player, obstacle, projectile, empty };
const EntityLookupResult = union(EntityLookupUnionType) { player: *Player, obstacle: *Wall, projectile: *Projectile, empty: void };

fn getEntityFromPosition(players: *const []Player, projectiles: *const []Projectile, obstacles: *const ObstacleGenerator, position: *const [2]u32) EntityLookupResult {
    for (players.*) |*player| {
        if (player.isAlive and isPositionEqual(&player.position[0], position)) {
            return EntityLookupResult{ .player = player };
        }
    }

    for (projectiles.*) |*projectile| {
        if (projectile.isAlive and isPositionEqual(&projectile.position[0], position)) {
            return EntityLookupResult{ .projectile = projectile };
        }
    }

    const obstacle = &obstacles.walls[position[0]][position[1]];

    return switch (obstacle.variant) {
        .brick, .concrete => EntityLookupResult{ .obstacle = obstacle },
        else => EntityLookupResult{ .empty = {} },
    };
}

fn getPositionFromDirection(position: *const [2]u32, direction: Direction, gridSize: usize) ?[2]u32 {
    const x = position[0];
    const y = position[1];

    return switch (direction) {
        .Up => if (y == 0) null else .{ x, y - 1 },
        .Down => if (y == gridSize - 1) null else .{ x, y + 1 },
        .Left => if (x == 0) null else .{ x - 1, y },
        .Right => if (x == gridSize - 1) null else .{ x + 1, y },
    };
}

fn spawnProjectile(projectiles: *const []Projectile, projectile: Projectile) void {
    for (projectiles.*) |*p| {
        if (!p.isAlive) {
            p.* = projectile;

            break;
        }
    }
}

pub fn main() !void {
    var gridScreenManager = GridScreenManager.init();

    const windowConfig = RL.ConfigFlags{ .window_resizable = true, .window_highdpi = true };

    log("Initializing window");
    std.debug.print("Setting window config flags: {}\n", .{windowConfig});

    RL.setConfigFlags(windowConfig);
    RL.setTargetFPS(300);

    log("Initializing memory allocator");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    log("Initializing window");
    RL.initWindow(gridScreenManager.screenWidth, gridScreenManager.screenHeight, "battlecity-zig");
    defer RL.closeWindow();

    log("Initializing textures");
    // Load Textures
    const spriteSheet = RL.Texture.init("resources/tanks.png");
    defer spriteSheet.unload();

    log("Initializing players");
    var players = try allocator.alloc(Player, 4);
    defer allocator.free(players);

    players[0] = Player{ .isAlive = true, .direction = Direction.Down, .position = .{ .{ 0, 0 }, .{ 0, 0 } }, .movementControls = .{
        KeyboardControl{ .key = RL.KeyboardKey.w },
        KeyboardControl{ .key = RL.KeyboardKey.d },
        KeyboardControl{ .key = RL.KeyboardKey.s },
        KeyboardControl{ .key = RL.KeyboardKey.a },
    }, .fireControl = KeyboardControl{ .key = RL.KeyboardKey.space } };

    log("Initializing projectiles pool");
    var arenaAllocator = std.heap.ArenaAllocator.init(allocator);
    defer arenaAllocator.deinit();
    const bulletAllocator = arenaAllocator.allocator();
    const projectiles = try bulletAllocator.alloc(Projectile, 100);
    defer bulletAllocator.free(projectiles);

    log("Initializing obstacles");
    var obstacles = try ObstacleGenerator.init(10, 10, &allocator);
    defer obstacles.deinit();

    log("Initializing pickups");
    const pickups = try allocator.alloc(Pickup, 100);
    defer allocator.free(pickups);

    log("Initializing animation pool");
    const animations = try allocator.alloc(Animation, 100);
    defer allocator.free(animations);

    log("Initializing game ticks");
    var timeSinceStart: f32 = 0.0;
    var lastTick: f32 = 0.0;
    const gameTickRate = 1.0 / 10.0;

    while (!RL.windowShouldClose()) {
        const deltaTime = RL.getFrameTime();
        timeSinceStart += deltaTime;
        const tickFloat = timeSinceStart / gameTickRate;
        const tickFloor = std.math.floor(tickFloat);

        for (players) |*player| {
            player.updateControls();
        }

        if (tickFloor > lastTick) {
            lastTick = tickFloor;
            log("Game tick");

            // Move bullets
            // Check collisions with boundaries
            // Check collisions with players
            // Check collisions with other bullets
            // Check collisions with obstacles
            for (projectiles) |*projectile| {
                if (!projectile.isAlive) {
                    continue;
                }

                const nextPosition = getPositionFromDirection(projectile.position[0][0..], projectile.direction, gridScreenManager.gridSize) orelse {
                    projectile.destroy();
                    continue;
                };

                const traceResult = getEntityFromPosition(&players, &projectiles, &obstacles, &nextPosition);

                switch (traceResult) {
                    .player => |_| {
                        // player.takeDamage();
                        projectile.destroy();
                        // animation.spawn();
                    },
                    .projectile => |projectileB| {
                        projectile.destroy();
                        projectileB.destroy();
                        // animation.spawn();
                    },
                    .obstacle => |wall| {
                        switch (wall.variant) {
                            .brick => {
                                wall.setVariant(WallType.empty);
                                projectile.destroy();
                                // animation.spawn(AnimationType.Explosion);
                            },
                            .concrete => {
                                projectile.destroy();
                                // animation.spawn(AnimationType.Explosion);
                            },
                            else => {},
                        }
                    },
                    .empty => {},
                }

                projectile.position = .{ nextPosition, projectile.position[0] };
            }

            // Move players
            // Check collisions with boundaries
            // Check collisions with other players
            // Check collisions with bullets
            // Check collisions with obstacles
            for (players) |*player| {
                if (!player.isAlive) {
                    continue;
                }

                const newDirection = player.getPressedDirection();

                if (player.fireControl.isKeyDown) {
                    const spawnPosition = getPositionFromDirection(&player.position[0], player.direction, gridScreenManager.gridSize);

                    if (spawnPosition) |position| {
                        const traceResult = getEntityFromPosition(&players, &projectiles, &obstacles, &position);
                        switch (traceResult) {
                            .player => |_| {
                                // player.takeDamage();
                                // animation.spawn();
                            },
                            .projectile => |projectileB| {
                                projectileB.destroy();
                                // animation.spawn();
                            },
                            .obstacle => |wall| {
                                switch (wall.variant) {
                                    .brick => {
                                        wall.setVariant(WallType.empty);
                                        // animation.spawn(AnimationType.Explosion);
                                    },
                                    .concrete => {
                                        // animation.spawn(AnimationType.Explosion);
                                    },
                                    else => {},
                                }
                            },
                            .empty => {
                                spawnProjectile(&projectiles, Projectile{ .isAlive = true, .direction = player.direction, .position = .{ position, position } });
                            },
                        }
                    }
                }

                if (newDirection) |dir| {
                    player.direction = dir;

                    const x = player.position[0][0];
                    const y = player.position[0][1];

                    const position: [2]u32 = getPositionFromDirection(player.position[0][0..], player.direction, gridScreenManager.gridSize) orelse {
                        player.position = .{ player.position[0], player.position[0] };
                        continue;
                    };

                    const traceResult = getEntityFromPosition(&players, &projectiles, &obstacles, &position);

                    var canMove = true;
                    switch (traceResult) {
                        .player => |_| {
                            canMove = false;
                        },
                        .projectile => |projectile| {
                            projectile.destroy();
                            // animation.spawn();
                        },
                        // .pickup => |pickup| {
                        // if (player.tryTakePickup()) {
                        // pickup.destroy();
                        //
                        // }
                        // },
                        .obstacle => |wall| {
                            switch (wall.variant) {
                                .brick, .concrete => canMove = false,
                                else => {},
                            }
                        },
                        .empty => {},
                    }

                    if (canMove) {
                        player.position = .{ position, .{ x, y } };
                    } else {
                        player.position = .{ player.position[0], player.position[0] };
                    }
                } else {
                    player.position = .{ player.position[0], player.position[0] };
                }
            }

            // Update animation state
            for (animations) |*animation| {
                if (animation.isPlaying) {
                    animation.current += 1;

                    if (animation.current == animation.frames.len) {
                        // animation.destroy();
                        animation.isPlaying = false;
                    }
                }
            }
        }

        // Update window size
        if (RL.isWindowResized()) {
            log("Window resized");

            gridScreenManager.setScreenSize(RL.getScreenWidth(), RL.getScreenHeight());
        }

        // Draw
        RL.beginDrawing();
        defer RL.endDrawing();

        RL.clearBackground(RL.Color.black);

        for (pickups) |pickup| {
            const frame = switch (pickup.variant) {
                .health => spriteDb.HEALTH_PICKUP_TILE,
                .armor => spriteDb.ARMOR_PICKUP_TILE,
            };

            renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
                .position = RenderPosition{ .static = &pickup.position },
                .sprite = &frame,
            });
        }

        for (players) |player| {
            const playerSprite = spriteDb.getSpriteR(player.getSprite());

            const tickLerpState = (tickFloat - tickFloor);
            const interpolatedPosition = getInterpolatedPosition(&player.position, tickLerpState);

            renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
                .position = RenderPosition{ .dynamic = &interpolatedPosition },
                .sprite = &playerSprite,
            });
        }

        for (projectiles) |projectile| {
            if (!projectile.isAlive) {
                continue;
            }

            const frame = switch (projectile.direction) {
                .Down => spriteDb.SHELL_DOWN_TILE,
                .Left => spriteDb.SHELL_LEFT_TILE,
                .Up => spriteDb.SHELL_UP_TILE,
                .Right => spriteDb.SHELL_RIGHT_TILE,
            };

            const tickLerpState = (tickFloat - tickFloor);
            const interpolatedPosition = getInterpolatedPosition(&projectile.position, tickLerpState);

            renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
                .position = RenderPosition{ .dynamic = &interpolatedPosition },
                .sprite = &frame,
            });
        }

        for (obstacles.walls) |row| {
            for (row) |obstacle| {
                const spriteRect: ?([]const f32) = switch (obstacle.variant) {
                    .brick => spriteDb.getSprite(spriteDb.SpriteId.brick),
                    .concrete => spriteDb.getSprite(spriteDb.SpriteId.concrete),
                    .net => spriteDb.getSprite(spriteDb.SpriteId.net),
                    .empty => null,
                };

                if (spriteRect) |rect| {
                    renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
                        .position = RenderPosition{ .static = &obstacle.position },
                        .sprite = &rect,
                    });
                }
            }
        }

        for (animations) |animation| {
            if (animation.isPlaying) {
                const frame = animation.frames[animation.current];

                renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
                    .position = RenderPosition{ .static = &animation.position },
                    .sprite = &frame,
                });
            }
        }

        // for (renderEntities) |entity| {
        //     switch (entity) {
        //         .obstacle => |obstacle| {
        //             const spriteRect: ?([]const f32) = switch (obstacle.variant) {
        //                 .brick => spriteDb.getSprite(spriteDb.SpriteId.brick),
        //                 .concrete => spriteDb.getSprite(spriteDb.SpriteId.concrete),
        //                 .net => spriteDb.getSprite(spriteDb.SpriteId.net),
        //             };

        //             if (spriteRect) |rect| {
        //                 renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
        //                     .position = RenderPosition{ .static = &obstacle.position },
        //                     .sprite = &rect,
        //                 });
        //             }
        //         },
        //         .player => |player| {
        //             const playerSprite = spriteDb.getSpriteR(player.getSprite());

        //             const tickLerpState = (tickFloat - tickFloor);
        //             const interpolatedPosition = getInterpolatedPosition(&player.position, tickLerpState);

        //             renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
        //                 .position = RenderPosition{ .dynamic = &interpolatedPosition },
        //                 .sprite = &playerSprite,
        //             });
        //         },
        //         .animation => |animation| {
        //             const frame = animation.frames[animation.current];

        //             renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
        //                 .position = RenderPosition{ .static = &animation.position },
        //                 .sprite = &frame,
        //             });
        //         },
        //         .pickup => |pickup| {
        //             const frame = switch (pickup.variant) {
        //                 .health => spriteDb.HEALTH_PICKUP_TILE,
        //                 .armor => spriteDb.ARMOR_PICKUP_TILE,
        //             };

        //             renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
        //                 .position = RenderPosition{ .static = &pickup.position },
        //                 .sprite = &frame,
        //             });
        //         },
        //         .projectile => |projectile| {
        //             const frame = switch (projectile.direction) {
        //                 .Down => spriteDb.SHELL_DOWN_TILE,
        //                 .Left => spriteDb.SHELL_LEFT_TILE,
        //                 .Up => spriteDb.SHELL_UP_TILE,
        //                 .Right => spriteDb.SHELL_RIGHT_TILE,
        //             };

        //             const tickLerpState = (tickFloat - tickFloor);
        //             const interpolatedPosition = getInterpolatedPosition(&projectile.position, tickLerpState);

        //             renderSprite(&spriteSheet, &gridScreenManager, &RenderEntity{
        //                 .position = RenderPosition{ .dynamic = &interpolatedPosition },
        //                 .sprite = &frame,
        //             });
        //         },
        //     }
        // }

        RL.drawFPS(0, 0);
    }
}

pub fn isPositionEqual(positionA: *const [2]u32, positionB: *const [2]u32) bool {
    return positionA[0] == positionB[0] and positionA[1] == positionB[1];
}

const MovablePosition = [2][2]u32;
fn getInterpolatedPosition(position: *const MovablePosition, lerp: f32) [2]f32 {
    const interpolatedX = std.math.lerp(@as(f32, @floatFromInt(position[1][0])), @as(f32, @floatFromInt(position[0][0])), lerp);
    const interpolatedY = std.math.lerp(@as(f32, @floatFromInt(position[1][1])), @as(f32, @floatFromInt(position[0][1])), lerp);

    return .{ interpolatedX, interpolatedY };
}

const SpriteRenderer = struct {
    gridScreenManager: *const GridScreenManager,
    texture: *const RL.Texture,
};

const RenderPositionType = enum { static, dynamic };

const RenderPosition = union(RenderPositionType) {
    static: *const [2]u32,
    dynamic: *const [2]f32,
};

const RenderEntity = struct {
    position: RenderPosition,
    sprite: *const []const f32,
};

fn renderSprite(texture: *const RL.Texture, screenManager: *const GridScreenManager, args: *const RenderEntity) void {
    const originPosition = RL.Vector2.init(0.0, 0.0);
    const sourceRectangle = RL.Rectangle.init(args.sprite.ptr[0], args.sprite.ptr[1], spriteDb.TILE_SIZE, spriteDb.TILE_SIZE);
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
                row[x] = Wall.init(.{ @intCast(x), @intCast(y) }, WallType.empty);
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
                    0, 1 => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.brick),
                    2 => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.concrete),
                    3 => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.net),
                    else => Wall.init(.{ @intCast(x), @intCast(y) }, WallType.empty),
                };
                row[y] = newObstacle;
            }
        }

        const rowCount = self.walls.len;
        const colCount = self.walls[0].len;

        self.walls[0][0].setVariant(WallType.empty);
        self.walls[rowCount - 1][0].setVariant(WallType.empty);
        self.walls[0][colCount - 1].setVariant(WallType.empty);
        self.walls[rowCount - 1][colCount - 1].setVariant(WallType.empty);
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

    try std.testing.expectEqual(obstacles.walls[0][0].variant, WallType.empty);
    try std.testing.expectEqual(obstacles.walls[9][0].variant, WallType.empty);
    try std.testing.expectEqual(obstacles.walls[0][9].variant, WallType.empty);
    try std.testing.expectEqual(obstacles.walls[9][9].variant, WallType.empty);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
