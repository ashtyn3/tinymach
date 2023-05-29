const std = @import("std");
const memory = @import("memory.zig");
const ops = @import("instructions.zig");

const PAGE_SIZE = 65536;

const WrapData = union(ops.types) {
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

const Wrap = struct {
    data: WrapData,
    unwrap_type: ops.types,
};
pub const VM = struct {
    const Self = @This();

    stack: std.ArrayList(Wrap),
    mem: memory.memory,

    fn stack_ptr(self: *Self) usize {
        return @intCast(usize, self.stack.items.len - 1);
    }

    pub fn destroy(self: *Self) void {
        self.mem.destroyProg();
        _ = self.stack.deinit();
    }

    pub fn push(self: *Self, arg: Wrap) !void {
        try self.stack.append(arg);
    }
    pub fn pop(self: *Self) void {
        _ = self.stack.orderedRemove(self.stack_ptr());
    }

    fn wrap(self: *Self, t: ops.types) !Wrap {
        var wrapper: Wrap = undefined;
        switch (t) {
            .T_u8 => {
                wrapper.data = WrapData{ .T_u8 = self.mem.u8_() };
                wrapper.unwrap_type = ops.types.T_u8;
                return wrapper;
            },
            .T_u16 => {
                wrapper.data = WrapData{ .T_u16 = try self.mem.u16_() };
                wrapper.unwrap_type = ops.types.T_u16;
                return wrapper;
            },
            .T_u32 => {
                wrapper.data = WrapData{ .T_u32 = try self.mem.u32_() };
                wrapper.unwrap_type = ops.types.T_u32;
                return wrapper;
            },
            .T_u64 => {
                wrapper.data = WrapData{ .T_u64 = try self.mem.u64_() };
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
            var op = @intToEnum(ops.instructions, self.mem.u8_());
            _ = switch (op) {
                .INS_push => {
                    const t = self.mem.u8_();
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
                        const item: Wrap = f;

                        std.debug.print("{}: {}\n", .{ i, item });
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

pub fn VM_init(allocator: std.mem.Allocator) VM {
    var init = VM{
        .stack = std.ArrayList(Wrap).init(allocator),
        .mem = memory.memory_init(allocator),
    };

    return init;
}
