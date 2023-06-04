const std = @import("std");
const ops = @import("../instructions.zig");
const mem = @import("../memory.zig");

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

pub fn wrap(comptime e_T: ops.types, comptime T: type, dat: T) ops.vmErrors!mem.Wrap {
    var wrapper: mem.Wrap = undefined;
    wrapper.unwrap_type = e_T;

    switch (e_T) {
        .T_u8 => wrapper.data.T_u8 = dat,
        .T_u16 => wrapper.data.T_u16 = dat,
        .T_u32 => wrapper.data.T_u32 = dat,
        .T_u64 => wrapper.data.T_u64 = dat,
        else => return ops.vmErrors.badData,
    }

    return wrapper;
}
