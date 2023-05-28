const std = @import("std");
const memory = @import("memory.zig");

const PAGE_SIZE = 65536;
pub const VM = struct {
    const Self = @This();

    stack_alloc: std.heap.GeneralPurposeAllocator(.{}),
    stack: std.mem.Allocator,
    stack_items: []u8,
    stack_pointer: i64 = -1,
    mem: memory.memory,

    fn stack_ptr(self: *Self) usize {
        return @intCast(usize, self.stack_pointer);
    }
    pub fn push_u8(self: *Self, dat: u8) void {
        self.stack_pointer += 1;
        self.stack_items.ptr[self.stack_ptr()] = dat;
    }

    pub fn pop_u8(self: *Self) u8 {
        const data = self.stack_items.ptr[@intCast(usize, self.stack_pointer)];
        self.stack_pointer -= 1;
        return data;
    }

    pub fn push_u16(self: *Self, dat: u16) !void {
        const allocator = std.heap.page_allocator;
        var buffer = try allocator.alloc(u8, 2);
        defer allocator.free(buffer);
        std.mem.writeIntSliceLittle(u16, buffer, dat);
        self.stack_pointer += 2;
        self.stack_items.ptr[self.stack_ptr() - 1] = buffer[0];
        self.stack_items.ptr[self.stack_ptr()] = buffer[1];
    }

    pub fn pop_u16(self: *Self) u16 {
        var buffer = [_]u8{ self.stack_items.ptr[self.stack_ptr() - 1], self.stack_items.ptr[self.stack_ptr()] };
        return std.mem.readIntSlice(u16, &buffer, std.builtin.Endian.Little);
    }

    pub fn push_u32(self: *Self, dat: u32) !void {
        const allocator = std.heap.page_allocator;
        var buffer = try allocator.alloc(u8, 4);
        defer allocator.free(buffer);
        std.mem.writeIntSliceLittle(u32, buffer, dat);
        self.stack_pointer += 4;
        self.stack_items.ptr[self.stack_ptr() - 3] = buffer[0];
        self.stack_items.ptr[self.stack_ptr() - 2] = buffer[1];
        self.stack_items.ptr[self.stack_ptr() - 1] = buffer[2];
        self.stack_items.ptr[self.stack_ptr()] = buffer[3];
    }

    pub fn pop_u32(self: *Self) u32 {
        var buffer = [_]u8{ self.stack_items.ptr[self.stack_ptr() - 3], self.stack_items.ptr[self.stack_ptr() - 2], self.stack_items.ptr[self.stack_ptr() - 1], self.stack_items.ptr[self.stack_ptr()] };
        return std.mem.readIntSlice(u32, &buffer, std.builtin.Endian.Little);
    }

    pub fn push_u64(self: *Self, dat: u64) !void {
        const allocator = std.heap.page_allocator;
        var buffer = try allocator.alloc(u8, 8);
        defer allocator.free(buffer);
        std.mem.writeIntSliceLittle(u64, buffer, dat);
        self.stack_pointer += 8;
        self.stack_items.ptr[self.stack_ptr() - 7] = buffer[0];
        self.stack_items.ptr[self.stack_ptr() - 6] = buffer[1];
        self.stack_items.ptr[self.stack_ptr() - 5] = buffer[2];
        self.stack_items.ptr[self.stack_ptr() - 4] = buffer[3];
        self.stack_items.ptr[self.stack_ptr() - 3] = buffer[4];
        self.stack_items.ptr[self.stack_ptr() - 2] = buffer[5];
        self.stack_items.ptr[self.stack_ptr() - 1] = buffer[6];
        self.stack_items.ptr[self.stack_ptr()] = buffer[7];
    }

    pub fn pop_u64(self: *Self) u64 {
        var buffer = [_]u8{
            self.stack_items.ptr[self.stack_ptr() - 7],
            self.stack_items.ptr[self.stack_ptr() - 6],
            self.stack_items.ptr[self.stack_ptr() - 5],
            self.stack_items.ptr[self.stack_ptr() - 4],
            self.stack_items.ptr[self.stack_ptr() - 3],
            self.stack_items.ptr[self.stack_ptr() - 2],
            self.stack_items.ptr[self.stack_ptr() - 1],
            self.stack_items.ptr[self.stack_ptr()],
        };
        return std.mem.readIntSlice(u64, &buffer, std.builtin.Endian.Little);
    }
    pub fn destroy(self: *Self) void {
        self.mem.destroyProg();
        _ = self.stack_alloc.deinit();
    }
};

pub fn VM_init(allocator: std.mem.Allocator) VM {
    var stack = std.heap.GeneralPurposeAllocator(.{}){};
    var init = VM{
        .stack_alloc = stack,
        .stack = stack.allocator(),
        .stack_items = &[_]u8{},
        .mem = memory.memory_init(allocator),
    };
    if (init.stack.alloc(u8, PAGE_SIZE)) |s| {
        init.stack_items = s;
        return init;
    } else |e| {
        std.log.err("{}", .{e});
    }

    return init;
}

test "stack_ops" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var vm_inst = VM_init(gpa.allocator());

    var prog = [_]u8{ 0, 54, 4, 72 };
    try vm_inst.loadProg(&prog);

    try vm_inst.push_u64(std.math.maxInt(u64));
    var res_64: u64 = vm_inst.pop_u64();
    try std.testing.expect(res_64 == std.math.maxInt(u64));

    try vm_inst.push_u32(std.math.maxInt(u32));
    var res_32: u32 = vm_inst.pop_u32();
    try std.testing.expect(res_32 == std.math.maxInt(u32));

    try vm_inst.push_u16(std.math.maxInt(u16));
    var res_16: u16 = vm_inst.pop_u16();
    try std.testing.expect(res_16 == std.math.maxInt(u16));

    vm_inst.push_u8(std.math.maxInt(u8));
    try std.testing.expect(vm_inst.pop_u8() == std.math.maxInt(u8));

    vm_inst.destroyProg();
    defer _ = gpa.deinit();
}
