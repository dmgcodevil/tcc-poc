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
            return true;
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

    pub fn getDeps(self: *Graph, node: *Node) ![]*Node {
        var out = std.ArrayList(*Node).init(self.allocator);
        defer out.deinit();
        try self.getDeps_recursive(self.root, node, &out);
        return out.toOwnedSlice();
    }

    fn getDeps_recursive(self: *Graph, curr: *Node, node: *Node, out: *std.ArrayList(*Node)) !void {
        for (curr.child.items) |child| {
            try self.getDeps_recursive(child, node, out);
        }
        if (node.compare(curr) > 0 and curr != self.root) {
            try out.append(curr);
        }
    }

    pub fn deinit(self: *Graph) void {
        deinit_recursive(self.root);
    }

    fn deinit_recursive(node: *Node) void {
        for (node.child.items) |child| {
            deinit_recursive(child);
        }
        node.deinit();
    }

    pub fn print(self: *Graph) !void {
        try print_node(self.root);
    }

    fn print_node(node: *Node) !void {
        var str = try node.toString();
        defer node.allocator.free(str);
        std.debug.print("{s}\n", .{str});
        for (node.child.items) |child| {
            try print_node(child);
        }
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
    var graph = try init(allocator, 2);
    // create nodes
    var n1 = try createNode(allocator, "1", &[_]u32{ 1, 0 });
    var n2 = try createNode(allocator, "2", &[_]u32{ 2, 1 });
    var n3 = try createNode(allocator, "3", &[_]u32{ 2, 2 });
    var n4 = try createNode(allocator, "4", &[_]u32{ 3, 3 });
    var n5 = try createNode(allocator, "5", &[_]u32{ 1, 1 });
    defer graph.deinit();
    try graph.insert(n1);
    try graph.insert(n2);
    try graph.insert(n3);
    try graph.insert(n4);
    try graph.insert(n5);
    try graph.print();

    var n1Deps = try graph.getDeps(n1);
    var n2Deps = try graph.getDeps(n2);
    var n3Deps = try graph.getDeps(n3);
    var n4Deps = try graph.getDeps(n4);
    var n5Deps = try graph.getDeps(n5);
    defer std.testing.allocator.free(n1Deps);
    defer std.testing.allocator.free(n2Deps);
    defer std.testing.allocator.free(n3Deps);
    defer std.testing.allocator.free(n4Deps);
    defer std.testing.allocator.free(n5Deps);

    try std.testing.expect(std.mem.eql(*Node, n1Deps, &[_]*Node{}));
    try std.testing.expect(std.mem.eql(*Node, n2Deps, &[_]*Node{ n1, n5 }));
    try std.testing.expect(std.mem.eql(*Node, n3Deps, &[_]*Node{ n1, n5, n2 }));
    try std.testing.expect(std.mem.eql(*Node, n4Deps, &[_]*Node{ n1, n5, n2, n3 }));
    try std.testing.expect(std.mem.eql(*Node, n5Deps, &[_]*Node{n1}));
}
