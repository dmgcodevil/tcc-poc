const std = @import("std");
const testing = @import("std").testing;
const node_module = @import("node.zig");
const Node = node_module.Node;
const createNode = node_module.create;
const Allocator = std.mem.Allocator;

pub const Graph = struct {
    root: *Node,
    vector_size: u32,
    allocator: Allocator,

    //Inserts a new node into the graph.
    pub fn insert(self: *Graph, node: *Node) !void {
        if (self.exists(node)) return error.IllegalArgumentException;
        _ = try self.insert_recursive(self.root, node);
    }

    //Recursively inserts a new node into the tree.
    fn insert_recursive(self: *Graph, current: *Node, node: *Node) !bool {
        if (current.child.items.len == 0) {
            try current.child.append(node);
            return true;
        }

        // Find all child nodes that happened before the new node
        var hb_nodes = std.ArrayList(*Node).init(self.allocator);
        defer hb_nodes.deinit();
        for (current.child.items) |child| {
            if (node.compare(child) > 0) {
                try hb_nodes.append(child);
            }
        }
        if (hb_nodes.items.len > 0) {
            for (hb_nodes.items) |hb_node, i| {
                try node.child.append(hb_node);
                _ = current.child.orderedRemove(i);
            }
            try current.child.append(node);
        } else {
            // Recursively check each child node for insertion
            for (current.child.items) |child| {
                if (try self.insert_recursive(child, node)) return true;
            }
            return error.IllegalStateException; // unreachable code
        }

        return false;
    }

    pub fn exists(self: *Graph, node: *Node) bool {
        return exists_recursive(self.root, node);
    }

    fn exists_recursive(current: *Node, node: *Node) bool {
        if (current.equals(node)) return true;
        for (current.child.items) |child| {
            if (exists_recursive(child, node)) return true;
        }
        return false;
    }

    pub fn getDeps() void {}

    pub fn deinit(self: *Graph) void {
        self.root.deinit();
        //self.allocator.destroy(self);
    }
};

pub fn init(allocator: Allocator, comptime vector_size: u32) !Graph {
    const vector_clock = std.mem.zeroes([vector_size]u32);
    var root = try node_module.create(allocator, "root", &vector_clock);
    return Graph{ .vector_size = vector_size, .root = root, .allocator = allocator };
}

test "Test init function" {
    const allocator = testing.allocator;
    const vector_size: u32 = 10;
    var graph = try init(allocator, comptime vector_size);
    defer graph.deinit();
    try testing.expectEqual(vector_size, graph.vector_size);
}

// create nodes
// Node n1 = new Node("1", new int[]{1, 0});
// Node n2 = new Node("2", new int[]{2, 1});
// Node n3 = new Node("3", new int[]{2, 2});
// Node n4 = new Node("4", new int[]{3, 3});
// Node n5 = new Node("5", new int[]{1, 1});

test "Insert And Search Deps" {
    const allocator = testing.allocator;
    var graph = try init(allocator, 3);
    var n1 = try createNode(allocator, "1", &[_]u32{ 1, 2, 3 });
    defer graph.deinit();
    //defer n1.deinit();
    try graph.insert(n1);
    try testing.expect(graph.root.child.items[0] == n1);
}
