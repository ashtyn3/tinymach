const vm = @import("vm.zig");
const mem = @import("memory.zig");
pub const regs = enum { ip, r1, r2, r3, r4, r5, r6, r7 };

pub const Registers = struct {
    const Self = @This();
    // allocator: std.heap.GeneralPurposeAllocator(.{}),
    // register_alloc: std.mem.Allocator,
    registers: [8]mem.Wrap,

    pub fn set(self: *Self, idx: regs, dat: i64) void {
        self.registers[@intCast(usize, @enumToInt(idx))] = dat;
    }
    pub fn get(self: *Self, idx: regs) i64 {
        return self.registers[@intCast(usize, @enumToInt(idx))];
    }
};
