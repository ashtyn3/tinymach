const std = @import("std");
const vm = @import("vm.zig");
const ops = @import("instructions.zig");
const registers = @import("registers.zig");

pub const WrapData = union(ops.types) {
    T_u8: u8,
    T_u16: u16,
    T_u32: u32,
    T_u64: u64,

    T_i8: i8,
    T_i16: i16,
    T_i32: i32,
    T_i64: i64,

    T_f64: f64,
};

pub const Wrap = struct {
    data: WrapData,
    unwrap_type: ops.types,
};

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

pub const memory = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    prog: std.ArrayList(u8),
    registers: registers.Registers,

    pub fn load(self: *Self, prog: []u8) !void {
        try self.prog.appendSlice(prog);
    }

    pub fn destroyProg(self: *Self) void {
        self.prog.deinit();
    }
    pub fn u8_(self: *Self) u8 {
        var origin_ip = self.registers.get(registers.regs.ip);
        self.registers.set(registers.regs.ip, origin_ip + 1);

        var ip = @intCast(usize, origin_ip);

        return self.prog.items[ip];
    }

    pub fn u16_(self: *Self) !u16 {
        var origin_ip = self.registers.get(registers.regs.ip);
        self.registers.set(registers.regs.ip, origin_ip + 2);

        var ip = @intCast(usize, origin_ip);

        var int = try bufferInt(u16, &[_]u8{ self.prog.items[ip], self.prog.items[ip + 1] });
        return int;
    }

    pub fn u32_(self: *Self) !u32 {
        var origin_ip = self.registers.get(registers.regs.ip);
        self.registers.set(registers.regs.ip, origin_ip + 4);

        var ip = @intCast(usize, origin_ip);

        var int = try bufferInt(u32, &[_]u8{
            self.prog.items[ip],
            self.prog.items[ip + 1],
            self.prog.items[ip + 2],
            self.prog.items[ip + 3],
        });
        return int;
    }
    pub fn u64_(self: *Self) !u64 {
        var origin_ip = self.registers.get(registers.regs.ip);
        self.registers.set(registers.regs.ip, origin_ip + 8);

        var ip = @intCast(usize, origin_ip);

        var int = try bufferInt(u64, &[_]u8{
            self.prog.items[ip],
            self.prog.items[ip + 1],
            self.prog.items[ip + 2],
            self.prog.items[ip + 3],
            self.prog.items[ip + 4],
            self.prog.items[ip + 5],
            self.prog.items[ip + 6],
            self.prog.items[ip + 7],
        });
        return int;
    }
};

pub fn memory_init(allocator: std.mem.Allocator) memory {
    var regs_str = registers.Registers{
        .registers = undefined,
    };

    var init = memory{
        .allocator = allocator,
        .prog = std.ArrayList(u8).init(allocator),
        .registers = regs_str,
    };
    return init;
}
