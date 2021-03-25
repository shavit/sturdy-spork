const std = @import("std");
const testing = std.testing;

pub const TokenType = enum {
    illegal,
    eof,

    ident,
    int,

    assign,
    plus,
    minus,
    bang,
    asterisk,
    slash,
    lt,
    gt,
    eq,
    not_eq,

    comma,
    semicolon,

    lparen,
    rparen,
    lbrace,
    rbrace,

    @"fn",
    let,
    true,
    false,
    @"if",
    @"else",
    @"return",
};

pub const Token = struct {
    T: TokenType,
    literal: []const u8 = "",
};

pub fn lookup(ident: []const u8) ?Token {
    const table = std.ComptimeStringMap(Token, .{
        .{ "fn", Token{ .T = .@"fn", .literal = "fn" } },
        .{ "let", .{ .T = .let, .literal = "let" } },
        .{ "true", .{ .T = .true, .literal = "true" } },
        .{ "false", .{ .T = .false, .literal = "false" } },
        .{ "if", .{ .T = .@"if", .literal = "if" } },
        .{ "else", .{ .T = .@"else", .literal = "else" } },
        .{ "return", .{ .T = .@"return", .literal = "return" } },
    });

    return table.get(ident);
}

test "token lookup" {
    const TestCase = struct {
        arg: []const u8,
        expect: ?Token,
    };
    const testCases = [_]TestCase{
        .{ .arg = "", .expect = null },
        .{ .arg = "invalid", .expect = null },
        .{ .arg = "fn", .expect = .{ .T = .@"fn" } },
        .{ .arg = "let", .expect = .{ .T = .let } },
        .{ .arg = "true", .expect = .{ .T = .true } },
        .{ .arg = "false", .expect = .{ .T = .false } },
        .{ .arg = "if", .expect = .{ .T = .@"if" } },
        .{ .arg = "else", .expect = .{ .T = .@"else" } },
        .{ .arg = "return", .expect = .{ .T = .@"return" } },
    };

    for (testCases) |t| {
        const res: ?Token = lookup(t.arg);
        if (res != null and t.expect != null) {
            try testing.expect(res.?.T == t.expect.?.T);
        } else {
            try testing.expect(res == null);
            try testing.expect(t.expect == null);
        }
    }
}
