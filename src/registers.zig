const vm = @import("vm.zig");
const mem = @import("memory.zig");
const ops = @import("instructions.zig");
const utils = @import("utils/utils.zig");
pub const regs = enum { ip, r1, r2, r3, r4, r5, r6, r7 };

pub const Registers = struct {
    const Self = @This();
    // allocator: std.heap.GeneralPurposeAllocator(.{}),
    // register_alloc: std.mem.Allocator,
    registers: [8]mem.Wrap,

    pub fn init(self: *Self) void {
        self.registers[0] = utils.wrap(ops.types.T_u64, u64, 0);
    }
    pub fn set(self: *Self, idx: regs, dat: mem.Wrap) void {
        self.registers[@intCast(usize, @enumToInt(idx))] = dat;
    }
    pub fn get(self: *Self, idx: regs) mem.Wrap {
        return self.registers[@intCast(usize, @enumToInt(idx))];
    }
};
