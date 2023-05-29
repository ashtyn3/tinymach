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
    try vm_inst.mem.prog.append(@enumToInt(inst.T_u16));
    try vm_inst.mem.prog.appendSlice(try mem.intBuffer(u16, 2000));

    try vm_inst.mem.prog.append(@enumToInt(inst.INS_push));
    try vm_inst.mem.prog.append(@enumToInt(inst.T_u16));
    try vm_inst.mem.prog.appendSlice(try mem.intBuffer(u16, 2020));

    try vm_inst.mem.prog.append(@enumToInt(inst.INS_push));
    try vm_inst.mem.prog.append(@enumToInt(inst.T_u32));
    try vm_inst.mem.prog.appendSlice(try mem.intBuffer(u32, 2_000_000));

    try vm_inst.mem.prog.append(@enumToInt(inst.nop));

    try vm_inst.exec();
    std.log.info("{any}", .{vm_inst.pop_u32()});
    std.log.info("{any}", .{vm_inst.pop_u16()});

    vm_inst.destroy();
    defer _ = gpa.deinit();
}
