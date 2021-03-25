const std = @import("std");
const testing = std.testing;

const Parser = struct {
    // lex: Lexer,
    errors: []const []const u8,
};
