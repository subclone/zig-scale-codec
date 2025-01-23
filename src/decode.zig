//! Comptime SCALE decode implementation for primitive types.
const std = @import("std");

/// Decode a SCALE encoded `u8a`
pub fn Decode(comptime T: type, value: *const [@divExact(@typeInfo(T).Int.bits, 8)]u8) !T {
    switch (@typeInfo(T)) {
        .Int, .ComptimeInt => {
            return std.mem.readInt(T, value, std.builtin.Endian.little);
        },
        else => return error.OutOfRange("Unsupported type: only integer types are supported for SCALE decoding"),
    }
}

test "Decode zero-length input" {
    const T = u8;
    const invalidEncoded = [_]u8{};
    const decoded = Decode(T, &invalidEncoded);
    try std.testing.expectError(error.OutOfRange, decoded);
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

test "Decode i8" {
    const i8Value: i8 = -42;
    const i8Encoded = [_]u8{0xD6}; // -42 in two's complement
    const decodedI8 = try Decode(i8, &i8Encoded);
    try std.testing.expect(decodedI8 == i8Value);
}

test "Decode i16" {
    const i16Value: i16 = -42;
    const i16Encoded = [_]u8{ 0xD6, 0xFF }; // -42 in two's complement
    const decodedI16 = try Decode(i16, &i16Encoded);
    try std.testing.expect(decodedI16 == i16Value);
}

test "Decode i32" {
    const i32Value: i32 = -42;
    const i32Encoded = [_]u8{ 0xD6, 0xFF, 0xFF, 0xFF }; // -42 in two's complement
    const decodedI32 = try Decode(i32, &i32Encoded);
    try std.testing.expect(decodedI32 == i32Value);
}

test "Decode i64" {
    const i64Value: i64 = -42;
    const i64Encoded = [_]u8{ 0xD6, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF }; // -42 in two's complement
    const decodedI64 = try Decode(i64, &i64Encoded);
    try std.testing.expect(decodedI64 == i64Value);
}

test "Decode u8 max value" {
    const u8Value: u8 = std.math.maxInt(u8);
    const u8Encoded = [_]u8{0xFF};
    const decodedU8 = try Decode(u8, &u8Encoded);
    try std.testing.expect(decodedU8 == u8Value);
}

test "Decode u16 max value" {
    const u16Value: u16 = std.math.maxInt(u16);
    const u16Encoded = [_]u8{ 0xFF, 0xFF };
    const decodedU16 = try Decode(u16, &u16Encoded);
    try std.testing.expect(decodedU16 == u16Value);
}

test "Decode u32 max value" {
    const u32Value: u32 = std.math.maxInt(u32);
    const u32Encoded = [_]u8{ 0xFF, 0xFF, 0xFF, 0xFF };
    const decodedU32 = try Decode(u32, &u32Encoded);
    try std.testing.expect(decodedU32 == u32Value);
}

test "Decode u64 max value" {
    const u64Value: u64 = std.math.maxInt(u64);
    const u64Encoded = [_]u8{ 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
    const decodedU64 = try Decode(u64, &u64Encoded);
    try std.testing.expect(decodedU64 == u64Value);
}

test "Decode invalid input (incorrect length)" {
    const invalidEncoded = [_]u8{0x2A}; // Too short for u16
    const decoded = Decode(u16, &invalidEncoded);
    try std.testing.expectError(error.OutOfRange, decoded);
}

test "Decode unsupported type" {
    const unsupportedType = struct {};
    const encoded = [_]u8{0x00};
    const decoded = Decode(unsupportedType, &encoded);
    try std.testing.expectError(error.OutOfRange, decoded);
}
