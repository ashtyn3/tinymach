pub const instructions = enum(u8) {
    nop,
    stack_trace,

    // STACK OPS
    INS_push,
    INS_dup,
    INS_pop,

    // MATH OPS
    INS_add,
    INS_sub,
    INS_mul,
};

pub const types = enum(u8) {
    //TYPE OPS
    // float
    T_f64,

    // INTS
    // signed
    T_i32,
    T_i64,
    T_i16,
    T_i8,

    //unsigned
    T_u32,
    T_u64,
    T_u16,
    T_u8,
};
