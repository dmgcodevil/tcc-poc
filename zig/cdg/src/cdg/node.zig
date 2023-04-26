const std = @import("std");
const test_allocator = std.testing.allocator;

//Represents a node in a causal dependency graph.
pub const Node = struct {
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

    pub fn deinit(self: *Node) void {
        self.child.deinit();
    }
};

test "Node addChild" {
    var root = Node{
        .id = "root",
        .vector_clock = &[_]u32{ 1, 0, 0 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer root.deinit();
    var child = Node{
        .id = "child",
        .vector_clock = &[_]u32{ 1, 1, 0 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer child.deinit();
    try root.addChild(&child);
    try std.testing.expectEqual(root.child.items[0], &child);
}

test "Node compare" {
    var node1 = Node{
        .id = "node1",
        .vector_clock = &[_]u32{ 1, 2, 3 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node1.deinit();
    var node2 = Node{
        .id = "node2",
        .vector_clock = &[_]u32{ 1, 2, 4 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node2.deinit();
    var node3 = Node{
        .id = "node3",
        .vector_clock = &[_]u32{ 1, 2, 3 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node3.deinit();
    try std.testing.expect(node1.compare(&node2) == -1);
    try std.testing.expect(node2.compare(&node1) == 1);
    try std.testing.expect(node1.compare(&node3) == 0);
}

test "Node equals" {
    var node1 = Node{
        .id = "node1",
        .vector_clock = &[_]u32{ 1, 2, 3 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node1.deinit();
    var node2 = Node{
        .id = "node2",
        .vector_clock = &[_]u32{ 1, 2, 4 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node2.deinit();
    var node3 = Node{
        .id = "node1",
        .vector_clock = &[_]u32{ 1, 2, 3 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node3.deinit();
    try std.testing.expect(node1.equals(&node2) == false);
    try std.testing.expect(node2.equals(&node1) == false);
    try std.testing.expect(node1.equals(&node3) == true);
}

test "Node hashCode" {
    var node1 = Node{
        .id = "node1",
        .vector_clock = &[_]u32{ 1, 2, 3 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node1.deinit();
    var node2 = Node{
        .id = "node2",
        .vector_clock = &[_]u32{ 1, 2, 4 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node2.deinit();
    var node3 = Node{
        .id = "node1",
        .vector_clock = &[_]u32{ 1, 2, 3 },
        .child = std.ArrayList(*Node).init(test_allocator),
    };
    defer node3.deinit();
    try std.testing.expect(node1.hashCode() != node2.hashCode());
    try std.testing.expect(node1.hashCode() == node3.hashCode());
}
