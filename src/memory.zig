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
pub const regs = enum { ip, r1, r2, r3, r4, r5, r6, r7 };

pub const registers = struct {
    const Self = @This();
    // allocator: std.heap.GeneralPurposeAllocator(.{}),
    // register_alloc: std.mem.Allocator,
    registers: [8]i64,

    pub fn set(self: *Self, idx: regs, dat: i64) void {
        self.registers[@intCast(usize, @enumToInt(idx))] = dat;
    }
    pub fn get(self: *Self, idx: regs) i64 {
        return self.registers[@intCast(usize, @enumToInt(idx))];
    }
};

pub const memory = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    prog: std.ArrayList(u8),
    registers: registers,

    pub fn load(self: *Self, prog: []u8) !void {
        try self.prog.appendSlice(prog);
    }

    pub fn destroyProg(self: *Self) void {
        self.prog.deinit();
    }
    pub fn u8_(self: *Self) u8 {
        var origin_ip = self.registers.get(regs.ip);
        self.registers.set(regs.ip, origin_ip + 1);

        var ip = @intCast(usize, origin_ip);

        return self.prog.items[ip];
    }

    pub fn u16_(self: *Self) !u16 {
        var origin_ip = self.registers.get(regs.ip);
        self.registers.set(regs.ip, origin_ip + 2);

        var ip = @intCast(usize, origin_ip);

        var int = try bufferInt(u16, &[_]u8{ self.prog.items[ip], self.prog.items[ip + 1] });
        return int;
    }

    pub fn u32_(self: *Self) !u32 {
        var origin_ip = self.registers.get(regs.ip);
        self.registers.set(regs.ip, origin_ip + 4);

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
        var origin_ip = self.registers.get(regs.ip);
        self.registers.set(regs.ip, origin_ip + 8);

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
    var regs_str = registers{
        .registers = [8]i64{ 0, 0, 0, 0, 0, 0, 0, 0 },
    };

    var init = memory{
        .allocator = allocator,
        .prog = std.ArrayList(u8).init(allocator),
        .registers = regs_str,
    };
    return init;
}
