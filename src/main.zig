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

const EntityManager = @import("./entities/entity.manager.zig").EntityManager;

const EntityLookupUnionType = enum(u8) { player, obstacle, projectile, empty };
const EntityLookupResult = union(EntityLookupUnionType) { player: *Player, obstacle: *Obstacles.Obstacle, projectile: *Projectile, empty: void };

fn getEntityFromPosition(players: *const []Player, projectiles: *const []Projectile, obstacles: *Obstacles.ObstacleGridManager, position: *const [2]u32) EntityLookupResult {
    // const entities = std.ArrayList(EntityLookupResult).init();

    for (players.*) |*player| {
        if (player.isAlive and isPositionEqual(&player.position[0], position)) {
            // entities.append(EntityLookupResult{ .player = player });
            return EntityLookupResult{ .player = player };
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

const GRID_SIZE: u32 = 50;

pub fn main() !void {
    var gridScreenManager = GridScreenManager.init(GRID_SIZE);

    // std.fs.cwd().
    // std.fs.openFileAbsolute(absolute_path: []const u8, flags: File.OpenFlags)
    // const ioReader = std.io.bufferedReader(reader: anytype)
    // std.json.reader(allocator: Allocator, io_reader: anytype)
    // const parsed = try std.json.parseFromSlice(
    //     Place,
    //     test_allocator,
    //     \\{ "lat": 40.684540, "long": -74.401422 }
    // ,
    //     .{},
    // );
    // defer parsed.deinit();

    const windowConfig = RL.ConfigFlags{ .window_resizable = true, .window_highdpi = true };

    log("Initializing window");
    std.debug.print("Setting window config flags: {}\n", .{windowConfig});

    RL.setConfigFlags(windowConfig);
    // RL.setTargetFPS(300);

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

    var entityManager = try EntityManager.init(allocator, 50, 4, 50, 5);
    defer entityManager.deinit();

    try entityManager.spawn(.{ .player = Player{ .id = 0, .isAlive = true, .direction = Direction.Down, .spawnDirection = Direction.Down, .position = .{ .{ 0, 0 }, .{ 0, 0 } }, .movementControls = .{
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
    } } });
    try entityManager.spawn(.{ .animation = Animation.spawn(entityManager.players.items[0].position[0]) });

    log("Initializing obstacles");
    var obstacles = try Obstacles.ObstacleGridManager.init(GRID_SIZE, GRID_SIZE, &allocator);
    obstacles.generateObstacles();
    defer obstacles.deinit();

    log("Initializing game ticks");
    var timeSinceStart: f32 = 0.0;
    var lastTick: f32 = 0.0;
    const gameTickRate = 1.0 / 10.0;

    while (!RL.windowShouldClose()) {
        const deltaTime = RL.getFrameTime();
        timeSinceStart += deltaTime;
        const tickFloat = timeSinceStart / gameTickRate;
        const tickFloor = std.math.floor(tickFloat);

        for (entityManager.players.items) |*player| {
            player.updateControls();
        }

        if (tickFloor > lastTick) {
            lastTick = tickFloor;
            log("Game tick");

            const projectilesLength = entityManager.projectiles.items.len;
            for (0..projectilesLength) |index| {
                const reverseIndex = projectilesLength - index - 1;
                var projectile = &entityManager.projectiles.items[reverseIndex];

                const nextPosition = getPositionFromDirection(projectile.position[0][0..], projectile.direction, gridScreenManager.gridSize) orelse {
                    entityManager.destroy(.{ .entity = .projectile, .index = reverseIndex });
                    // projectile.destroy();
                    continue;
                };

                @memcpy(&projectile.position[1], &projectile.position[0]);
                projectile.position[0] = nextPosition;
            }

            for (entityManager.players.items) |*player| {
                if (!player.isAlive) {
                    continue;
                }

                if (player.getPressedDirection()) |movementDirection| {
                    player.direction = movementDirection;

                    var currentPositionCopy: [2]u32 = undefined;
                    std.mem.copyForwards(u32, &currentPositionCopy, &player.position[0]);

                    var nextPosition = getPositionFromDirection(player.position[0][0..], movementDirection, gridScreenManager.gridSize) orelse currentPositionCopy;
                    const obstacle = obstacles.obstacles[nextPosition[0]][nextPosition[1]];
                    if (obstacle) |o| {
                        switch (o.variant) {
                            .brick, .concrete => {
                                nextPosition = currentPositionCopy;
                            },
                            .net => {},
                        }
                    }

                    std.mem.swap([2]u32, &player.position[1], &player.position[0]);
                    player.position[0] = nextPosition;
                } else {
                    std.mem.copyForwards(u32, &player.position[1], player.position[0][0..]);
                }

                if (player.fireControl.isKeyDown) {
                    if (getPositionFromDirection(&player.position[0], player.direction, gridScreenManager.gridSize)) |projectileSpawnPosition| {
                        try entityManager.spawn(.{ .projectile = Projectile{ .direction = player.direction, .isAlive = true, .position = .{ projectileSpawnPosition, projectileSpawnPosition } } });
                    }
                }
            }

            var projectilesToDestroyHashMap = std.AutoHashMap(usize, bool).init(allocator);
            defer projectilesToDestroyHashMap.deinit();

            // 1. Check direct collision when 2 objects are at the same place
            // 2. Check indirect collision when 2 movable objects can potentially phase through each other
            // |>|<|
            // |<|>|
            for (entityManager.projectiles.items, 0..) |*projectile, index| {
                const staticPositionTraceResult = entityManager.getEntitiesAtPosition(projectile.position[0]);
                defer staticPositionTraceResult.deinit();

                for (staticPositionTraceResult.items) |lookupResult| {
                    switch (lookupResult) {
                        .player => |player| {
                            log("Projectile hit player");
                            player.health -= 1;

                            projectilesToDestroyHashMap.put(index, true) catch |err| {
                                std.debug.print("Failed to set projectile for removal: {}\n", .{err});
                            };
                        },
                        .projectile => |projectileB| {
                            if (projectileB != projectile) {
                                log("Projectile hit another projectile");

                                projectilesToDestroyHashMap.put(index, true) catch |err| {
                                    std.debug.print("Failed to set projectile for removal: {}\n", .{err});
                                };
                            }
                        },
                        .pickup => {},
                    }
                }

                const phaseCollisionTraceResult = entityManager.getEntityFromMovementHistory(.{
                    projectile.position[1],
                    projectile.position[0],
                });
                defer phaseCollisionTraceResult.deinit();

                for (phaseCollisionTraceResult.items) |lookupResult| {
                    switch (lookupResult) {
                        .player => |player| {
                            log("Projectile hit player");
                            player.health -= 1;

                            projectilesToDestroyHashMap.put(index, true) catch |err| {
                                std.debug.print("Failed to set projectile for removal: {}\n", .{err});
                            };
                        },
                        .projectile => |projectileB| {
                            if (projectileB != projectile) {
                                log("Projectile hit another projectile. HOW?");

                                projectilesToDestroyHashMap.put(index, true) catch |err| {
                                    std.debug.print("Failed to set projectile for removal: {}\n", .{err});
                                };
                                // entityManager.destroy(.{ .entity = .projectile, .index =  ?? });
                                // entityManager.destroy(.{ .entity = .projectile, .index =  ?? });
                            }
                        },
                        .pickup => {},
                    }
                }

                const x = projectile.position[0][0];
                const y = projectile.position[0][1];

                if (obstacles.obstacles[x][y]) |*obstacle| {
                    switch (obstacle.variant) {
                        .brick => {
                            obstacles.obstacles[x][y] = null;
                            try entityManager.spawn(.{ .animation = Animation.explosion(projectile.position[0]) });
                            projectilesToDestroyHashMap.put(index, true) catch |err| {
                                std.debug.print("Failed to set projectile for removal: {}\n", .{err});
                            };
                        },
                        .concrete => {
                            try entityManager.spawn(.{ .animation = Animation.explosion(projectile.position[0]) });
                            projectilesToDestroyHashMap.put(index, true) catch |err| {
                                std.debug.print("Failed to set projectile for removal: {}\n", .{err});
                            };
                        },
                        .net => {},
                    }
                }
            }

            const keysSlice = try getSliceOfKeysFromHashMap(usize, allocator, &projectilesToDestroyHashMap);
            defer allocator.free(keysSlice);
            std.mem.sort(usize, keysSlice, {}, std.sort.desc(usize));
            for (keysSlice) |projectileIndex| {
                entityManager.destroy(.{ .entity = .projectile, .index = projectileIndex });
            }

            // Update animation state
            const animationsLength = entityManager.animations.items.len;
            for (0..animationsLength) |index| {
                const reverseIndex = animationsLength - index - 1;
                var animation = &entityManager.animations.items[reverseIndex];
                animation.current += 1;

                if (animation.current == animation.frames.len) {
                    entityManager.destroy(.{ .entity = .animation, .index = reverseIndex });
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

        for (entityManager.pickups.items) |pickup| {
            const frame: [4]f32 = switch (pickup.variant) {
                .health => comptime SpriteDB.getSprite(SpriteDB.SpriteId.health_pickup),
                .armor => comptime SpriteDB.getSprite(SpriteDB.SpriteId.armor_pickup),
            };

            Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                .position = Renderer.RenderPosition{ .static = &pickup.position },
                .sprite = &frame,
            });
        }

        for (entityManager.players.items) |player| {
            const playerSprite = SpriteDB.getSprite(player.getSprite());

            const tickLerpState = (tickFloat - tickFloor);
            const interpolatedPosition = getInterpolatedPosition(&player.position, tickLerpState);

            Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                .position = Renderer.RenderPosition{ .dynamic = &interpolatedPosition },
                .sprite = &playerSprite,
            });
        }

        for (entityManager.projectiles.items) |projectile| {
            if (!projectile.isAlive) {
                continue;
            }

            const frame = switch (projectile.direction) {
                .Down => comptime SpriteDB.getSprite(SpriteDB.SpriteId.shell_down),
                .Left => comptime SpriteDB.getSprite(SpriteDB.SpriteId.shell_left),
                .Up => comptime SpriteDB.getSprite(SpriteDB.SpriteId.shell_up),
                .Right => comptime SpriteDB.getSprite(SpriteDB.SpriteId.shell_right),
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
                        .brick => comptime SpriteDB.getSprite(SpriteDB.SpriteId.brick),
                        .concrete => comptime SpriteDB.getSprite(SpriteDB.SpriteId.concrete),
                        .net => comptime SpriteDB.getSprite(SpriteDB.SpriteId.net),
                    };

                    Renderer.renderSprite(&spriteSheet, &gridScreenManager, &Renderer.RenderEntity{
                        .position = Renderer.RenderPosition{ .static = &o.position },
                        .sprite = &spriteRect,
                    });
                }
            }
        }

        for (entityManager.animations.items) |animation| {
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

fn getSliceOfKeysFromHashMap(comptime T: type, allocator: std.mem.Allocator, hasMap: *std.AutoHashMap(T, bool)) ![]T {
    var arr = std.ArrayList(usize).init(allocator);
    var iterator = hasMap.keyIterator();
    while (iterator.next()) |projIndex| {
        try arr.append(projIndex.*);
    }
    return try arr.toOwnedSlice();
}
