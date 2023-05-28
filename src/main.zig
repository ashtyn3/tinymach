const std = @import("std");
const vm = @import("vm.zig");
const mem = @import("memory.zig");
const inst = @import("instructions.zig").instructions;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    var vm_inst = vm.VM_init(gpa.allocator());
    var prog = [_]u8{};
    try vm_inst.mem.load(&prog);
    try vm_inst.mem.prog.append(@enumToInt(inst.INS_push));
    try vm_inst.mem.prog.appendSlice(try mem.intBuffer(u16, 2000));
    try vm_inst.mem.prog.append(@enumToInt(inst.INS_pop));

    std.log.info("{}", .{vm_inst.mem.u8_()});
    std.log.info("{}", .{try vm_inst.mem.u16_()});
    std.log.info("{}", .{vm_inst.mem.u8_()});

    vm_inst.destroy();
    defer _ = gpa.deinit();
}
