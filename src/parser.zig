const std = @import("std");
const testing = std.testing;

const lexer = @import("lexer");
const Lexer = lexer.Lexer;
const token = @import("token");
const Token = token.Token;
const TokenType = token.TokenType;
const ast = @import("ast");

pub const Parser = struct {
    const Self = @This();
    lex: Lexer,
    tok_curr: Token,
    tok_peek: Token,
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

    fn next_token(self: *Self) void {
        self.tok_curr = self.tok_peek;
        self.tok_peek = self.lex.next_token();
    }

    fn parse(self: *Self) ast.Program {
        const program = ast.Program{};
        while (self.tok_curr.T != TokenType.eof) {
            const stmt = self.parse_statement();
            if (stmt != null) {}
            self.next_token();
        }
        return program;
    }

    fn parse_statement(self: *Self) ?ast.Statement {
        if (self.tok_curr.T == TokenType.eof) {
            return null;
        }
        return null;
    }
};

test "return statements" {
    const TestCase = struct {
        input: []const u8,
        num_stmt: u8,
    };
    const testCases = [_]TestCase{
        .{ .input = "return 1; return 2; return 3;", .num_stmt = 3 },
    };

    for (testCases) |t| {
        const l = Lexer.init(t.input);
        const p = Parser.init(l);
        const program = p.parse();

        try testing.expect(program.statements.len == t.num_stmt);
    }
}
