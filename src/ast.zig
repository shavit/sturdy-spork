const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const Token = @import("token").Token;

pub const StatementType = enum {
    let,
};

pub const Statement = struct {
    const Self = @This();
    t: StatementType,
    literal: []const u8,
    str: []const u8,

    fn toString(self: *Self) []const u8 {
        return switch (self) {
            else => letToString(),
        };
    }

    fn letToString() []const u8 {
        return "";
    }
};

pub const Program = struct {
    const Self = @This();
    statements: []const Statement,

    fn init() Self {
        return Self{ .statements = &[_]Statement{} };
    }

    fn toString(self: *Self) []const u8 {
        //var buf: [1024 * 16]u8 = undefined;
        if (self.statements.len > 2) {
            return "2";
        }

        return "";
    }
};

const Identifier = struct {
    const Self = @This();
    token: Token,
    value: []const u8,

    fn tokenLiteral(self: *Self) []const u8 {
        return self.token.literal;
    }
};

test "ast statements" {
    var program = Program.init();
    const expected = "";

    try testing.expect(mem.eql(u8, expected, program.toString()));
}
