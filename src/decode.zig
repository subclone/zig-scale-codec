//! Comptime SCALE decode implementation for primitive types.
const std = @import("std");

/// Decode a SCALE encoded `u8a`
pub fn Decode(comptime T: type, value: *const [@divExact(@typeInfo(T).Int.bits, 8)]u8) !T {
    switch (@typeInfo(T)) {
        .Int, .ComptimeInt => {
            return std.mem.readInt(T, value, std.builtin.Endian.little);
        },
        else => return error.OutOfRange("Unsupported type for SCALE decoding"),
    }
}

test "Decode u8" {
    const u8Value: u8 = 42;
    const u8Encoded = [_]u8{0x2A};
    const decodedU8 = try Decode(u8, &u8Encoded);
    try std.testing.expect(decodedU8 == u8Value);
}

test "Decode u16" {
    const u16Value: u16 = 42;
    const u16Encoded = [_]u8{ 0x2A, 0x00 };
    const decodedU16 = try Decode(u16, &u16Encoded);
    try std.testing.expect(decodedU16 == u16Value);
}

test "Decode u32" {
    const u32Value: u32 = 42;
    const u32Encoded = [_]u8{ 0x2A, 0x00, 0x00, 0x00 };
    const decodedU32 = try Decode(u32, &u32Encoded);
    try std.testing.expect(decodedU32 == u32Value);
}

test "Decode u64" {
    const u64Value: u64 = 42;
    const u64Encoded = [_]u8{ 0x2A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    const decodedU64 = try Decode(u64, &u64Encoded);
    try std.testing.expect(u64Value == decodedU64);
}
