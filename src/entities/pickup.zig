pub const HealthPickup = struct {
    amount: u32,
};
pub const ArmorPickup = struct { amount: u32 };
pub const PickupVariantType = enum(u8) { health, armor };
pub const PickupVariant = union(PickupVariantType) { health: HealthPickup, armor: ArmorPickup };
pub const Pickup = struct { position: [2]u32, variant: PickupVariant };
