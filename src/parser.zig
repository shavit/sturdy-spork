const std = @import("std");
const testing = std.testing;

const lexer = @import("lexer");
const Lexer = lexer.Lexer;

pub const Parser = struct {
    const Self = @This();
    lex: Lexer,
    errors: []const []const u8,
    prefix_parse_fns: []u8,
    infix_parse_fns: []u8,

    fn init(l: Lexer) Self {
        return Self{
            .lex = l,
            .errors = .{},
            .prefix_parse_fns = .{},
            .infix_parse_fns = .{},
        };
    }
};
