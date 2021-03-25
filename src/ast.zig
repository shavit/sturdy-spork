const Statement = struct {
    literal: []const u8,
    str: []const u8,
};

pub const Program = struct {
    statements: []const Statement,
};
