//! Comptime SCALE encode implementation for primitive types.

const std = @import("std");

/// Encode a primitive type as SCALE bytes.
pub fn Encode(comptime T: type, value: T) ![@sizeOf(T)]u8 {
    var bytes: [@sizeOf(T)]u8 = undefined;

    switch (@typeInfo(T)) {
        .Int, .ComptimeInt => {
            std.mem.writeInt(T, bytes[0..@sizeOf(T)], value, std.builtin.Endian.little);
        },
        .Bool => {
            if (value) {
                bytes[0] = 1;
            } else {
                bytes[0] = 0;
            }
        },
        else => return error.OutOfRange("Not an integer type"),
    }

    return bytes;
}

test "Uint32 encode" {
    const bytes = try Encode(u32, 1);
    const expected = [_]u8{ 0x01, 0, 0, 0 };
    try std.testing.expectEqual(bytes, expected);

    const bytes2 = try Encode(u32, 16383);
    const expected2 = [_]u8{ 0xff, 0x3f, 0, 0 };
    try std.testing.expectEqual(bytes2, expected2);

    const bytes3 = try Encode(u32, 3221225473);
    const expected3 = [_]u8{ 0x01, 0, 0, 0xc0 };
    try std.testing.expectEqual(bytes3, expected3);

    const u32_max = try Encode(u32, std.math.maxInt(u32));
    const expected4 = [_]u8{ 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(u32_max, expected4);
}

test "Uint64 encode" {
    const bytes = try Encode(u64, 1);
    const expected = [_]u8{ 0x01, 0, 0, 0, 0, 0, 0, 0 };
    try std.testing.expectEqual(bytes, expected);

    const bytes2 = try Encode(u64, 1073741823);
    const expected2 = [_]u8{ 0xff, 0xff, 0xff, 0x3f, 0, 0, 0, 0 };
    try std.testing.expectEqual(bytes2, expected2);

    const u64_max = try Encode(u64, std.math.maxInt(u64));
    const expected3 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(u64_max, expected3);
}

test "Uint128 encode" {
    const bytes = try Encode(u128, 1);
    const expected = [_]u8{ 0x01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    try std.testing.expectEqual(bytes, expected);

    const bytes2 = try Encode(u128, 123456789012345);
    const expected2 = [_]u8{ 121, 223, 13, 134, 72, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    try std.testing.expectEqual(bytes2, expected2);

    const bytes3 = try Encode(u128, 1234567890123456789012345);
    const expected3 = [_]u8{ 121, 223, 226, 61, 68, 166, 54, 15, 110, 5, 1, 0, 0, 0, 0, 0 };

    try std.testing.expectEqual(bytes3, expected3);

    const u128_max = try Encode(u128, std.math.maxInt(u128));
    const expected4 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(u128_max, expected4);
}

test "Int32 encode" {
    const bytes = try Encode(i32, 1);
    const expected = [_]u8{ 0x01, 0, 0, 0 };
    try std.testing.expectEqual(bytes, expected);

    const bytes2 = try Encode(i32, -1);
    const expected2 = [_]u8{ 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(bytes2, expected2);

    const bytes3 = try Encode(i32, 1073741823);
    const expected4 = [_]u8{ 0xff, 0xff, 0xff, 0x3f };
    try std.testing.expectEqual(bytes3, expected4);

    const bytes4 = try Encode(i32, -16383);
    const expected3 = [_]u8{ 0x01, 0xc0, 0xff, 0xff };
    try std.testing.expectEqual(bytes4, expected3);

    const bytes5 = try Encode(i32, -1073741823);
    const expected5 = [_]u8{ 0x01, 0x00, 0x00, 0xc0 };
    try std.testing.expectEqual(bytes5, expected5);
}

test "Int64 encode" {
    const bytes = try Encode(i64, 1);
    const expected = [_]u8{ 0x01, 0, 0, 0, 0, 0, 0, 0 };
    try std.testing.expectEqual(bytes, expected);

    const bytes2 = try Encode(i64, -1);
    const expected2 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };

    try std.testing.expectEqual(bytes2, expected2);

    const bytes3 = try Encode(i64, -1073741823);
    const expected3 = [_]u8{ 0x01, 0x00, 0x00, 0xc0, 0xff, 0xff, 0xff, 0xff };

    try std.testing.expectEqual(bytes3, expected3);

    const bytes4 = try Encode(i64, -9223372036854775807);
    const expected4 = [_]u8{ 0x01, 0, 0, 0, 0, 0, 0, 0x80 };

    try std.testing.expectEqual(bytes4, expected4);
}

test "Int128 encode" {
    const bytes = try Encode(i128, 1);
    const expected = [_]u8{ 0x01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    try std.testing.expectEqual(bytes, expected);

    const bytes2 = try Encode(i128, -1);
    const expected2 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };

    try std.testing.expectEqual(bytes2, expected2);

    const bytes3 = try Encode(i128, -123456789012345);
    const expected3 = [_]u8{ 135, 32, 242, 121, 183, 143, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };

    try std.testing.expectEqual(bytes3, expected3);

    const bytes4 = try Encode(i128, -1234567890123456789012345);

    const expected4 = [_]u8{ 135, 32, 29, 194, 187, 89, 201, 240, 145, 250, 254, 255, 255, 255, 255, 255 };

    try std.testing.expectEqual(bytes4, expected4);
}

test "Bool encode" {
    const bytes = try Encode(bool, true);
    const expected = [_]u8{1};
    try std.testing.expectEqual(bytes, expected);
    const bytes2 = try Encode(bool, false);
    const expected2 = [_]u8{0};
    try std.testing.expectEqual(bytes2, expected2);
}
