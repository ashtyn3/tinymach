const std = @import("std");
const vm = @import("vm.zig");
const mem = @import("memory.zig");
const i = @import("instructions.zig");
const utils = @import("utils/utils.zig");
const inst = i.instructions;
const types = i.types;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    var vm_inst = vm.VM_init(gpa.allocator());
    var prog = [_]u8{};
    try vm_inst.mem.load(&prog);
    try vm_inst.mem.prog.append(@enumToInt(inst.INS_push));
    try vm_inst.mem.prog.append(@enumToInt(types.T_u16));
    try vm_inst.mem.prog.appendSlice(try utils.intBuffer(u16, 20));

    try vm_inst.mem.prog.append(@enumToInt(inst.INS_push));
    try vm_inst.mem.prog.append(@enumToInt(types.T_u32));
    try vm_inst.mem.prog.appendSlice(try utils.intBuffer(u32, 20_000));

    try vm_inst.mem.prog.append(@enumToInt(inst.stack_trace));
    try vm_inst.mem.prog.append(@enumToInt(inst.INS_dup));

    try vm_inst.mem.prog.append(@enumToInt(inst.stack_trace));
    try vm_inst.mem.prog.append(@enumToInt(inst.INS_pop));

    try vm_inst.mem.prog.append(@enumToInt(inst.stack_trace));

    try vm_inst.mem.prog.append(@enumToInt(inst.nop));

    try vm_inst.exec();

    vm_inst.destroy();
    defer _ = gpa.deinit();
}
