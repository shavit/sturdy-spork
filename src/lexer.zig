const std = @import("std");
const ascii = std.ascii;
const testing = std.testing;
const mem = std.mem;

const token = @import("token.zig");
const Token = token.Token;

fn is_kinda_var(c: u8) bool {
    return switch (c) {
        '0'...'9', 'A'...'Z', 'a'...'z', '_' => true,
        else => false,
    };
}
fn is_kinda_num(c: u8) bool {
    return ascii.isDigit(c);
}

pub const Lexer = struct {
    const Self = @This();
    input: []const u8,
    c: u8 = 0x0, // current character
    char_i: usize = 0, // current index
    next_i: usize = 0, // next index

    pub fn init(input: []const u8) Self {
        var l = Self{ .input = input };
        l.read_char();

        return l;
    }

    fn read_char(self: *Self) void {
        if (self.next_i >= self.input.len) {
            self.c = 0x0;
        } else {
            self.c = self.input[self.next_i];
        }

        self.char_i = self.next_i;
        self.next_i += 1;
    }

    fn peek_char(self: *Self) u8 {
        if (self.next_i >= self.input.len) {
            return 0;
        } else {
            return self.input[self.next_i];
        }
    }

    pub fn next_token(self: *Self) Token {
        self.cap_whitespace();
        const nt: Token = switch (self.c) {
            '=' => blk: {
                if (self.peek_char() == '=') {
                    self.read_char();
                    break :blk .{ .T = .eq, .literal = "==" };
                } else {
                    break :blk .{ .T = .assign, .literal = "=" };
                }
            },
            '+' => .{ .T = .plus, .literal = "+" },
            '-' => .{ .T = .minus, .literal = "-" },
            '!' => blk: {
                if (self.peek_char() == '=') {
                    self.read_char();
                    break :blk .{ .T = .not_eq, .literal = "!=" };
                } else {
                    break :blk .{ .T = .bang, .literal = "!" };
                }
            },
            '/' => .{ .T = .slash, .literal = "/" },
            '*' => .{ .T = .asterisk, .literal = "*" },
            '<' => .{ .T = .lt, .literal = "<" },
            '>' => .{ .T = .gt, .literal = ">" },
            ';' => .{ .T = .semicolon, .literal = ";" },
            '(' => .{ .T = .lparen, .literal = "(" },
            ')' => .{ .T = .rparen, .literal = ")" },
            ',' => .{ .T = .comma, .literal = "," },
            '{' => .{ .T = .lbrace, .literal = "{" },
            '}' => .{ .T = .rbrace, .literal = "}" },
            0 => .{ .T = .eof, .literal = "" },
            'a'...'z', 'A'...'Z', '_' => return self.read_lookup_word(is_kinda_var, .ident),
            '0'...'9' => return self.read_lookup_word(is_kinda_num, .int),
            else => .{ .T = .illegal, .literal = &[1]u8{self.c} },
        };
        self.read_char();

        return nt;
    }

    fn cap_whitespace(self: *Self) void {
        while (ascii.isWhitespace(self.c)) self.read_char();
    }

    fn read_lookup_word(self: *Self, comptime legit: fn (u8) bool, T: token.TokenType) Token {
        const start_i = self.char_i;
        while (legit(self.c)) self.read_char();

        const literally = self.input[start_i..self.char_i];
        if (token.lookup(literally)) |t| {
            return t;
        } else {
            return .{ .T = T, .literal = literally };
        }
    }
};

test "lexer next token" {
    const input: []const u8 =
        "let twelve = 12;\n" ++ "let three = 3;\n" ++ "let add = fn(x, y) {\n" ++ "  x + y;\n" ++ "};\n" ++ "\n" ++ "let result = add(twelve, three);\n" ++ "!-/*9;\n" ++ "3 < 11 > 9;\n" ++ "\n" ++ "if (0 < 24) {\n" ++ "  return true;\n" ++ "} else {\n" ++ "  return false;\n" ++ "};\n" ++ "\n" ++ "15 == 15;\n" ++ "17 != 18;\n";
    const TokenType = token.TokenType;
    const TestCase = struct {
        token: TokenType,
        literal: []const u8,
    };
    const testCases = [_]TestCase{
        .{ .token = .let, .literal = "let" },
        .{ .token = .ident, .literal = "twelve" },
        .{ .token = .assign, .literal = "=" },
        .{ .token = .int, .literal = "12" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .let, .literal = "let" },
        .{ .token = .ident, .literal = "three" },
        .{ .token = .assign, .literal = "=" },
        .{ .token = .int, .literal = "3" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .let, .literal = "let" },
        .{ .token = .ident, .literal = "add" },
        .{ .token = .assign, .literal = "=" },
        .{ .token = .@"fn", .literal = "fn" },
        .{ .token = .lparen, .literal = "(" },
        .{ .token = .ident, .literal = "x" },
        .{ .token = .comma, .literal = "," },
        .{ .token = .ident, .literal = "y" },
        .{ .token = .rparen, .literal = ")" },
        .{ .token = .lbrace, .literal = "{" },
        .{ .token = .ident, .literal = "x" },
        .{ .token = .plus, .literal = "+" },
        .{ .token = .ident, .literal = "y" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .rbrace, .literal = "}" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .let, .literal = "let" },
        .{ .token = .ident, .literal = "result" },
        .{ .token = .assign, .literal = "=" },
        .{ .token = .ident, .literal = "add" },
        .{ .token = .lparen, .literal = "(" },
        .{ .token = .ident, .literal = "twelve" },
        .{ .token = .comma, .literal = "," },
        .{ .token = .ident, .literal = "three" },
        .{ .token = .rparen, .literal = ")" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .bang, .literal = "!" },
        .{ .token = .minus, .literal = "-" },
        .{ .token = .slash, .literal = "/" },
        .{ .token = .asterisk, .literal = "*" },
        .{ .token = .int, .literal = "9" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .int, .literal = "3" },
        .{ .token = .lt, .literal = "<" },
        .{ .token = .int, .literal = "11" },
        .{ .token = .gt, .literal = ">" },
        .{ .token = .int, .literal = "9" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .@"if", .literal = "if" },
        .{ .token = .lparen, .literal = "(" },
        .{ .token = .int, .literal = "0" },
        .{ .token = .lt, .literal = "<" },
        .{ .token = .int, .literal = "24" },
        .{ .token = .rparen, .literal = ")" },
        .{ .token = .lbrace, .literal = "{" },
        .{ .token = .@"return", .literal = "return" },
        .{ .token = .true, .literal = "true" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .rbrace, .literal = "}" },
        .{ .token = .@"else", .literal = "else" },
        .{ .token = .lbrace, .literal = "{" },
        .{ .token = .@"return", .literal = "return" },
        .{ .token = .false, .literal = "false" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .rbrace, .literal = "}" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .int, .literal = "15" },
        .{ .token = .eq, .literal = "==" },
        .{ .token = .int, .literal = "15" },
        .{ .token = .semicolon, .literal = ";" },
        .{ .token = .int, .literal = "17" },
        .{ .token = .not_eq, .literal = "!=" },
        .{ .token = .int, .literal = "18" },
        .{ .token = .semicolon, .literal = ";" },
    };

    var l = Lexer.init(input);
    for (testCases) |t| {
        const tkn = l.next_token();
        if (tkn.T != t.token) {
            std.debug.print("\n\terror reading token. Got:\n {any}\nLiteral:\n{s}\n", .{ tkn.T, tkn.literal });
            std.debug.print("\n\ttkn={any} | args={any} {s}\n\n", .{ tkn.T, t.token, t.literal });
        }
        try testing.expect(tkn.T == t.token);
        try testing.expect(mem.eql(u8, tkn.literal, t.literal));
    }
}
