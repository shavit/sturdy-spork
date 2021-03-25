const std = @import("std");

const Lexer = struct {
    input: []const u8,
    char_i: u16,
    read_i: u16,
    b: u8,
};
