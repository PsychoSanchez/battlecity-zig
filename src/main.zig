const std = @import("std");
const RL = @import("raylib");

const log = @import("./debug.zig").log;

const SpriteDB = @import("./sprite.db.zig");

const Renderer = @import("./core/render.zig");

const KeyboardControl = @import("./core/controls.zig").KeyboardControl;

const GridScreenManager = @import("./core/grid.zig").GridScreenManager;
const Direction = @import("./core/grid.zig").Direction;
const getPositionFromDirection = @import("./core/grid.zig").getPositionFromDirection;

const Player = @import("./entities/player.zig").Player;
const Pickup = @import("./entities/pickup.zig").Pickup;
const Animation = @import("./entities/animation.zig").Animation;
const Projectile = @import("./entities/projectile.zig").Projectile;
const Obstacles = @import("./entities/obstacle.zig");

const EntityManager = @import("./entities/entity.manager.zig");

const EntityLookupUnionType = enum(u8) { player, obstacle, projectile, empty };
const EntityLookupResult = union(EntityLookupUnionType) { player: *Player, obstacle: *Obstacles.Obstacle, projectile: *Projectile, empty: void };

fn getEntityFromPosition(players: *const []?Player, projectiles: *const []Projectile, obstacles: *Obstacles.ObstacleGridManager, position: *const [2]u32) EntityLookupResult {
    // const entities = std.ArrayList(EntityLookupResult).init();

    for (players.*) |*n_player| {
        if (n_player.*) |*player| {
            if (player.isAlive and isPositionEqual(&player.position[0], position)) {
                // entities.append(EntityLookupResult{ .player = player });
                return EntityLookupResult{ .player = player };
            }
        }
    }

    for (projectiles.*) |*projectile| {
        if (projectile.isAlive and isPositionEqual(&projectile.position[0], position)) {
            // entities.append(EntityLookupResult{ .projectile = projectile });
            return EntityLookupResult{ .projectile = projectile };
        }
    }

    // for (pickups.*) |*pickup| {
    //     if (pickup.isAlive and isPositionEqual(&pickup.position[0], position)) {
    //         entities.append(EntityLookupResult{ .pickup = pickup });
    //     }
    // }

    const n_obstacle: *?Obstacles.Obstacle = &obstacles.obstacles[position[0]][position[1]];

    if (n_obstacle.*) |*obstacle| {
        return EntityLookupResult{ .obstacle = obstacle };
    } else {
        return EntityLookupResult{ .empty = {} };
    }

    // entities.append(switch (obstacle.variant) {
    //     .brick, .concrete => EntityLookupResult{ .obstacle = obstacle },
    //     else => EntityLookupResult{ .empty = {} },
    // });

    // return entities;
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
    var players = try allocator.alloc(?Player, 4);
    @memset(players, null);
    defer allocator.free(players);

    players[0] = Player{ .id = 0, .isAlive = true, .direction = Direction.Down, .spawnDirection = Direction.Down, .position = .{ .{ 0, 0 }, .{ 0, 0 } }, .movementControls = .{
        KeyboardControl{ .key = RL.KeyboardKey.w },
        KeyboardControl{ .key = RL.KeyboardKey.d },
        KeyboardControl{ .key = RL.KeyboardKey.s },
        KeyboardControl{ .key = RL.KeyboardKey.a },
    }, .fireControl = KeyboardControl{ .key = RL.KeyboardKey.space }, .tiles = .{
        SpriteDB.SpriteId.tank_1_up,
        SpriteDB.SpriteId.tank_1_right,
        SpriteDB.SpriteId.tank_1_down,
        SpriteDB.SpriteId.tank_1_left,
        SpriteDB.SpriteId.armored_tank_1_up,
        SpriteDB.SpriteId.armored_tank_1_right,
        SpriteDB.SpriteId.armored_tank_1_down,
        SpriteDB.SpriteId.armored_tank_1_left,
    } };

    log("Initializing projectiles pool");
    var arenaAllocator = std.heap.ArenaAllocator.init(allocator);
    defer arenaAllocator.deinit();
    const bulletAllocator = arenaAllocator.allocator();
    const projectiles = try bulletAllocator.alloc(Projectile, 100);
    defer bulletAllocator.free(projectiles);

    log("Initializing obstacles");
    var obstacles = try Obstacles.ObstacleGridManager.init(10, 10, &allocator);
    obstacles.generateObstacles();
    defer obstacles.deinit();

    log("Initializing pickups");
    const pickups = try allocator.alloc(?Pickup, 100);
    @memset(pickups, null);
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

        for (players) |*n_player| {
            if (n_player.*) |*player| {
                player.updateControls();
            }
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
                        EntityManager.spawnExplosionAnimation(&animations, nextPosition);
                    },
                    .projectile => |projectileB| {
                        projectile.destroy();
                        projectileB.destroy();
                        EntityManager.spawnExplosionAnimation(&animations, nextPosition);
                    },
                    .obstacle => |wall| {
                        switch (wall.variant) {
                            .brick => {
                                obstacles.setObstacle(null, wall.position);
                                projectile.destroy();
                                EntityManager.spawnExplosionAnimation(&animations, nextPosition);
                            },
                            .concrete => {
                                projectile.destroy();
                                EntityManager.spawnExplosionAnimation(&animations, nextPosition);
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
            for (players) |*n_player| {
                if (n_player.*) |*player| {
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
                                    EntityManager.spawnExplosionAnimation(&animations, position);
                                },
                                .projectile => |projectileB| {
                                    projectileB.destroy();
                                    EntityManager.spawnExplosionAnimation(&animations, position);
                                },
                                .obstacle => |wall| {
                                    switch (wall.variant) {
                                        .brick => {
                                            obstacles.setObstacle(null, wall.position);
                                            EntityManager.spawnExplosionAnimation(&animations, position);
                                        },
                                        .concrete => {
                                            EntityManager.spawnExplosionAnimation(&animations, position);
                                        },
                                        else => {},
                                    }
                                },
                                .empty => {
                                    EntityManager.spawnProjectile(&projectiles, Projectile{ .isAlive = true, .direction = player.direction, .position = .{ position, position } });
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
                                EntityManager.spawnExplosionAnimation(&animations, position);
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

        for (pickups) |n_pickup| {
            if (n_pickup) |pickup| {
                const frame: [4]f32 = switch (pickup.variant) {
                    .health => SpriteDB.getSprite(SpriteDB.SpriteId.health_pickup),
                    .armor => SpriteDB.getSprite(SpriteDB.SpriteId.armor_pickup),
                };

                Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                    .position = Renderer.RenderPosition{ .static = &pickup.position },
                    .sprite = &frame,
                });
            }
        }

        for (players) |n_player| {
            if (n_player) |player| {
                const playerSprite = SpriteDB.getSprite(player.getSprite());

                const tickLerpState = (tickFloat - tickFloor);
                const interpolatedPosition = getInterpolatedPosition(&player.position, tickLerpState);

                Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                    .position = Renderer.RenderPosition{ .dynamic = &interpolatedPosition },
                    .sprite = &playerSprite,
                });
            }
        }

        for (projectiles) |projectile| {
            if (!projectile.isAlive) {
                continue;
            }

            const frame = switch (projectile.direction) {
                .Down => SpriteDB.getSprite(SpriteDB.SpriteId.shell_down),
                .Left => SpriteDB.getSprite(SpriteDB.SpriteId.shell_left),
                .Up => SpriteDB.getSprite(SpriteDB.SpriteId.shell_up),
                .Right => SpriteDB.getSprite(SpriteDB.SpriteId.shell_right),
            };

            const tickLerpState = (tickFloat - tickFloor);
            const interpolatedPosition = getInterpolatedPosition(&projectile.position, tickLerpState);

            Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                .position = Renderer.RenderPosition{ .dynamic = &interpolatedPosition },
                .sprite = &frame,
            });
        }

        for (obstacles.obstacles) |row| {
            for (row) |obstacle| {
                if (obstacle) |o| {
                    const spriteRect = switch (o.variant) {
                        .brick => SpriteDB.getSprite(SpriteDB.SpriteId.brick),
                        .concrete => SpriteDB.getSprite(SpriteDB.SpriteId.concrete),
                        .net => SpriteDB.getSprite(SpriteDB.SpriteId.net),
                    };

                    Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                        .position = Renderer.RenderPosition{ .static = &o.position },
                        .sprite = &spriteRect,
                    });
                }
            }
        }

        for (animations) |animation| {
            if (animation.isPlaying) {
                const frame = animation.frames.ptr[animation.current];

                Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                    .position = Renderer.RenderPosition{ .static = &animation.position },
                    .sprite = &SpriteDB.getSprite(frame),
                });
            }
        }

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
