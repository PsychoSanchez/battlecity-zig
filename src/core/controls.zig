const std = @import("std");
const RL = @import("raylib");

pub const KeyboardControl = struct {
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
