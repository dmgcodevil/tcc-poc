const std = @import("std");
const testing = @import("std").testing;
const node_module = @import("node.zig");
const Node = node_module.Node;
const Allocator = std.mem.Allocator;

pub const Graph = struct {
    root: *Node,
    vector_size: u32,
    allocator: Allocator,

    //Inserts a new node into the graph.
    pub fn insert(self: *Graph, node: *Node) !void {
        if (self.exists(node)) return error.IllegalArgumentException;
        try self.insert2(self.root, node);
    }

    //Recursively inserts a new node into the tree.
    fn insert2(self: *Graph, current: *Node, node: *Node) !bool {
        if (current.child.len() == 0) {
            current.child.add(node);
            return true;
        }

        // Find all child nodes that happened before the new node
        const hb_nodes = std.ArrayList(*Node).init(self.allocator);
        defer hb_nodes.deinit();
        for (current.child) |_, child| {
            if (node.compare(child) > 0) {
                try hb_nodes.append(child);
            }
        }
        if (hb_nodes.len() > 0) {
            for (hb_nodes) |i, hb_node| {
                try node.child.append(hb_node);
                current.child.orderedRemove(i);
            }
            try current.child.append(node);
        } else {
            // Recursively check each child node for insertion
            for (current.child) |_, child| {
                if (self.insert2(child, node)) return true;
            }
            return error.IllegalStateException;
        }

        return false;
    }

    pub fn exists(self: *Graph, node: *Node) bool {
        return exists2(self.root, node);
    }

    fn exists2(current: *Node, node: *Node) bool {
        if (current.equals(node)) return true;
        for (current.child) |_, child| {
            if (exists2(child, node)) return true;
        }
        return false;
    }

    pub fn getDeps() void {}

    pub fn deinit(self: *Graph) void {
        self.root.deinit();
    }
};

pub fn init(allocator: Allocator, comptime vector_size: u32) !Graph {
    const vector_clock = std.mem.zeroes([vector_size]u32);
    var root = try node_module.create(allocator, "root", &vector_clock, std.ArrayList(*Node).init(allocator));
    return Graph{ .vector_size = vector_size, .root = root, .allocator = allocator };
}

test "Test init function" {
    const allocator = testing.allocator;
    const vector_size: u32 = 10;
    var graph = try init(allocator, comptime vector_size);
    defer graph.deinit();
    try testing.expectEqual(vector_size, graph.vector_size);
}
