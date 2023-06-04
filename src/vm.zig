const std = @import("std");
const memory = @import("memory.zig");
const ops = @import("instructions.zig");

const PAGE_SIZE = 65536;

pub const VM = struct {
    const Self = @This();

    stack: std.ArrayList(memory.Wrap),
    mem: memory.memory,

    fn stack_ptr(self: *Self) usize {
        return @intCast(usize, self.stack.items.len - 1);
    }

    pub fn destroy(self: *Self) void {
        self.mem.destroyProg();
        _ = self.stack.deinit();
    }

    pub fn push(self: *Self, arg: memory.Wrap) !void {
        try self.stack.append(arg);
    }
    pub fn pop(self: *Self) void {
        _ = self.stack.orderedRemove(self.stack_ptr());
    }

    fn wrap(self: *Self, t: ops.types) !memory.Wrap {
        var wrapper: memory.Wrap = undefined;
        switch (t) {
            .T_u8 => {
                wrapper.data = memory.WrapData{ .T_u8 = try self.mem.u8_() };
                wrapper.unwrap_type = ops.types.T_u8;
                return wrapper;
            },
            .T_u16 => {
                wrapper.data = memory.WrapData{ .T_u16 = try self.mem.u16_() };
                wrapper.unwrap_type = ops.types.T_u16;
                return wrapper;
            },
            .T_u32 => {
                wrapper.data = memory.WrapData{ .T_u32 = try self.mem.u32_() };
                wrapper.unwrap_type = ops.types.T_u32;
                return wrapper;
            },
            .T_u64 => {
                wrapper.data = memory.WrapData{ .T_u64 = try self.mem.u64_() };
                wrapper.unwrap_type = ops.types.T_u64;
                return wrapper;
            },
            else => return wrapper,
        }
    }

    pub fn exec(self: *Self) !void {
        var nop = false;
        var last_inst: ops.instructions = undefined;
        _ = last_inst;
        while (nop == false) {
            var op = @intToEnum(ops.instructions, try self.mem.u8_());
            _ = switch (op) {
                .INS_push => {
                    const t = try self.mem.u8_();
                    const w_arg = try self.wrap(@intToEnum(ops.types, t));
                    try self.push(w_arg);
                    continue;
                },
                .INS_pop => {
                    self.pop();
                    continue;
                },
                .INS_dup => {
                    const top = self.stack.items[self.stack_ptr()];
                    try self.push(top);
                    continue;
                },
                .stack_trace => {
                    std.debug.print("STACK TRACE:\n", .{});
                    for (self.stack.items) |f, i| {
                        const item: memory.Wrap = f;

                        std.debug.print("{}: {}\n", .{ i, item.data });
                    }
                },
                .nop => {
                    nop = true;
                    continue;
                },
                else => {
                    continue;
                },
            };
        }
    }
};

pub fn VM_init(allocator: std.mem.Allocator) !VM {
    var init = VM{
        .stack = std.ArrayList(memory.Wrap).init(allocator),
        .mem = try memory.memory_init(allocator),
    };

    return init;
}
