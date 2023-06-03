const std = @import("std");

pub fn intBuffer(comptime T: type, dat: T) ![]u8 {
    const allocator = std.heap.page_allocator;
    const size = @typeInfo(T).Int.bits / 8;
    var buffer = try allocator.alloc(u8, size);
    std.mem.writeIntSliceLittle(T, buffer, dat);

    return buffer;
}

pub fn bufferInt(comptime T: type, dat: []u8) !T {
    return std.mem.readIntSlice(T, dat, std.builtin.Endian.Little);
}
