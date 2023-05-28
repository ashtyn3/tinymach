pub const instructions = enum(u8) {
    nop,

    // STACK OPS
    INS_push,
    INS_pop,

    // MATH OPS
    INS_add,
    INS_sub,
    INS_mul,

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
