const std = @import("std");
const test_allocator = std.testing.allocator;
const Allocator = std.mem.Allocator;

//Represents a node in a causal dependency graph.
pub const Node = struct {
    allocator: Allocator,
    id: []const u8, // the unique identifier of this node
    vector_clock: []const u32, // an array representing the vector clock of this node
    child: std.ArrayList(*Node), // the child nodes of this node

    // adds the given child node to the list of child nodes for this node
    pub fn addChild(self: *Node, node: *Node) !void {
        try self.child.append(node);
    }

    // Compares this node to another node based on their vector clocks.
    //
    // Parameters:
    // - that: the other node to compare to
    //
    // Returns:
    // - `-1` if this node happens before that
    // - `1` if that node happens before this
    // - `0` if they are concurrent
    pub fn compare(self: *Node, that: *Node) i32 {
        for (self.vector_clock) |_, i| {
            if (self.vector_clock[i] < that.vector_clock[i]) return -1;
            if (self.vector_clock[i] > that.vector_clock[i]) return 1;
        }
        return 0;
    }

    // returns true if the given node has the same identifier and vector clock as this node.
    pub fn equals(self: *Node, that: *Node) bool {
        if (self == that) return true;
        if (std.mem.eql(u8, self.id, that.id)) return true;
        return self.compare(that) == 0;
    }

    pub fn hashCode(self: *Node) u64 {
        return std.hash.CityHash64.hash(self.id);
    }

    pub fn childIds(self: *Node) ![]u8 {
        var list = std.ArrayList([]const u8).init(self.allocator);
        defer list.deinit();
        for (self.child.items) |child| {
            try list.append(child.id);
        }
        return try std.mem.join(self.allocator, ",", list.items);
    }

    pub fn toString(self: *Node) ![]u8 {
        var ids = try self.childIds();
        defer self.allocator.free(ids);
        return try std.fmt.allocPrint(self.allocator, "node[id={s}, vc={any}, child=[{s}]]", .{ self.id, self.vector_clock, ids });
    }

    pub fn deinit(self: *Node) void {
        self.child.deinit();
        self.allocator.destroy(self);
    }
};

pub fn create(allocator: Allocator, id: []const u8, vector_clock: []const u32) !*Node {
    return try create_with_child(allocator, id, vector_clock, std.ArrayList(*Node).init(allocator));
}

pub fn create_with_child(allocator: Allocator, id: []const u8, vector_clock: []const u32, child: std.ArrayList(*Node)) !*Node {
    var node = try allocator.create(Node);
    node.allocator = allocator;
    node.id = id;
    node.vector_clock = vector_clock;
    node.child = child;
    return node;
}

pub fn toIds(allocator: Allocator, nodes: []*Node) ![][]const u8 {
    var ids = std.ArrayList([]const u8).init(allocator);
    defer ids.deinit();
    for (nodes) |node| {
        try ids.append(node.id);
    }
    return ids.toOwnedSlice();
}

pub fn joinIds(allocator: Allocator, nodes: []*Node) ![]u8 {
    var ids = try toIds(allocator, nodes);
    defer allocator.free(ids);
    return try std.mem.join(allocator, ",", ids);
}

test "Node addChild" {
    var root = try create(
        test_allocator,
        "root",
        &[_]u32{ 1, 0, 0 },
    );
    defer root.deinit();
    var child = try create(
        test_allocator,
        "child",
        &[_]u32{ 1, 1, 0 },
    );
    defer child.deinit();
    try root.addChild(child);
    try std.testing.expectEqual(root.child.items[0], child);
}

test "Node compare" {
    var node1 = try create(
        test_allocator,
        "node1",
        &[_]u32{ 1, 2, 3 },
    );
    defer node1.deinit();
    var node2 = try create(
        test_allocator,
        "node2",
        &[_]u32{ 1, 2, 4 },
    );
    defer node2.deinit();
    var node3 = try create(
        test_allocator,
        "node3",
        &[_]u32{ 1, 2, 3 },
    );
    defer node3.deinit();
    try std.testing.expect(node1.compare(node2) == -1);
    try std.testing.expect(node2.compare(node1) == 1);
    try std.testing.expect(node1.compare(node3) == 0);
}

test "Node equals" {
    var node1 = try create(
        test_allocator,
        "node1",
        &[_]u32{ 1, 2, 3 },
    );
    defer node1.deinit();
    var node2 = try create(
        test_allocator,
        "node2",
        &[_]u32{ 1, 2, 4 },
    );
    defer node2.deinit();
    var node3 = try create(
        test_allocator,
        "node1",
        &[_]u32{ 1, 2, 3 },
    );
    defer node3.deinit();
    try std.testing.expect(node1.equals(node2) == false);
    try std.testing.expect(node2.equals(node1) == false);
    try std.testing.expect(node1.equals(node3) == true);
}

test "Node hashCode" {
    var node1 = try create(
        test_allocator,
        "node1",
        &[_]u32{ 1, 2, 3 },
    );
    defer node1.deinit();
    var node2 = try create(
        test_allocator,
        "node2",
        &[_]u32{ 1, 2, 4 },
    );
    defer node2.deinit();
    var node3 = try create(
        test_allocator,
        "node1",
        &[_]u32{ 1, 2, 3 },
    );
    defer node3.deinit();
    try std.testing.expect(node1.hashCode() != node2.hashCode());
    try std.testing.expect(node1.hashCode() == node3.hashCode());
}
