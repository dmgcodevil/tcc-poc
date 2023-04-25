const std = @import("std");
const allocator = std.heap.page_allocator;
const testing = std.testing;

pub const Buffer = struct {
    pos: u32 = 0,
    len: u32 = 0,
    capacity: u32,
    bytes: []u8,

    pub fn put(self: *Buffer, bytes: []const u8) !void {
        const bytes_len = @truncate(u32, bytes.len);
        if (self.len + bytes_len >= self.capacity) {
            self.capacity = std.math.max(self.len + bytes_len, self.capacity * 2);
            try self.resize(self.capacity);
        }
        std.mem.copy(u8, self.bytes[self.pos .. self.pos + bytes.len], bytes);
        self.pos += bytes_len + 1;
        self.len += bytes_len;
    }

    pub fn get(self: *Buffer, pos: u32, dest: []u8) !void {
        std.mem.copy(u8, dest, self.bytes[pos..dest.len]);
    }

    pub fn resize(self: *Buffer, new_size: u32) !void {
        self.bytes = try allocator.realloc(self.bytes, new_size);
    }

    pub fn clear(self: *Buffer) void {
        allocator.free(self.bytes);
        self.len = 0;
        self.pos = 0;
    }
};

pub fn init(capacity: u32) !Buffer {
    var bytes: []u8 = try allocator.alloc(u8, capacity);
    return Buffer{ .len = 0, .capacity = capacity, .bytes = bytes };
}

// tests

test "buffer put and get" {
    const buf_capacity: u32 = 10;
    var buf = try init(buf_capacity);

    const test_str = "hello world";
    const expected_len = test_str.len;
    try buf.put(test_str);

    var result = try allocator.alloc(u8, expected_len);
    defer allocator.free(result);
    try buf.get(0, result);

    try testing.expectEqualSlices(u8, test_str, result);
}

fn debug(msg: []const u8) void {
    std.debug.print("\n---\n{s}\n---\n", .{msg});
}

test "buffer resize" {
    const buf_capacity: u32 = 3;
    var buf = try init(buf_capacity);

    const str1 = "hello";
    const str2 = " world";
    try buf.put(str1);
    try buf.put(str2);

    var result = try allocator.alloc(u8, str1.len + str2.len + 1);
    defer allocator.free(result);
    try buf.get(0, result);

    try testing.expectEqualSlices(u8, str1, result[0..str1.len]);
    try testing.expectEqualSlices(u8, str2, result[str1.len + 1 ..]);
}

test "buffer clear" {
    const buf_capacity: u32 = 5;
    var buf = try init(buf_capacity);

    const test_str = "hello world";
    try buf.put(test_str);
    buf.clear();

    const expected_len: u32 = 0;
    try testing.expectEqual(expected_len, buf.len);
    try testing.expectEqual(expected_len, buf.pos);
}
