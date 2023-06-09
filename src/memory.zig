const std = @import("std");
const vm = @import("vm.zig");
const ops = @import("instructions.zig");
const registers = @import("registers.zig");
const utils = @import("utils/utils.zig");

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
    pub fn u8_(self: *Self) !u8 {
        var origin_ip = self.registers.get(registers.regs.ip).data.T_u64;
        var new_ip = self.registers.get(registers.regs.ip).data.T_u64 + 1;
        self.registers.set(registers.regs.ip, try utils.wrap(ops.types.T_u64, u64, new_ip));

        var ip = @intCast(usize, origin_ip);

        return self.prog.items[ip];
    }

    pub fn u16_(self: *Self) !u16 {
        var origin_ip = self.registers.get(registers.regs.ip).data.T_u64;
        var new_ip = self.registers.get(registers.regs.ip).data.T_u64 + 2;
        self.registers.set(registers.regs.ip, try utils.wrap(ops.types.T_u64, u64, new_ip));

        var ip = @intCast(usize, origin_ip);

        var int = try utils.bufferInt(u16, &[_]u8{ self.prog.items[ip], self.prog.items[ip + 1] });
        return int;
    }

    pub fn u32_(self: *Self) !u32 {
        var origin_ip = self.registers.get(registers.regs.ip).data.T_u64;
        var new_ip = self.registers.get(registers.regs.ip).data.T_u64 + 4;
        self.registers.set(registers.regs.ip, try utils.wrap(ops.types.T_u64, u64, new_ip));

        var ip = @intCast(usize, origin_ip);

        var int = try utils.bufferInt(u32, &[_]u8{
            self.prog.items[ip],
            self.prog.items[ip + 1],
            self.prog.items[ip + 2],
            self.prog.items[ip + 3],
        });
        return int;
    }
    pub fn u64_(self: *Self) !u64 {
        var origin_ip = self.registers.get(registers.regs.ip).data.T_u64;
        var new_ip = self.registers.get(registers.regs.ip).data.T_u64 + 8;
        self.registers.set(registers.regs.ip, try utils.wrap(ops.types.T_u64, u64, new_ip));

        var ip = @intCast(usize, origin_ip);

        var int = try utils.bufferInt(u64, &[_]u8{
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

pub fn memory_init(allocator: std.mem.Allocator) !memory {
    var regs_struct = try registers.register_init();
    var init = memory{
        .allocator = allocator,
        .prog = std.ArrayList(u8).init(allocator),
        .registers = regs_struct,
    };
    return init;
}
