package com.github.dmgcodevil;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public class GraphImpl implements Graph {
    private final Node root;
    private final int vectorSize;

    public GraphImpl(int vectorSize) {
        this.vectorSize = vectorSize;
        this.root = new Node("root", new int[vectorSize]);
    }


    /**
     * Inserts a new node into the tree.
     *
     * @param n the node to insert
     */
    @Override
    public void insert(Node n) {
        if (exists(n)) throw new IllegalArgumentException("node already exists in the graph");
        insert(root, n);
    }

    /**
     * Recursively inserts a new node into the tree.
     *
     * @param current the current node being checked
     * @param newNode the new node to insert
     * @return true if the new node was inserted, false otherwise
     */
    private boolean insert(Node current, Node newNode) {
        if (current.child.isEmpty()) {
            current.child.add(newNode);
            return true;
        }

        // Find all child nodes that happened before the new node
        List<Node> hbNodes = current.child.stream()
                .filter(child -> newNode.compareTo(child) > 0)
                .collect(Collectors.toList());

        if (!hbNodes.isEmpty()) {
            // Move all the happens-before nodes under the new node
            for (Node hbNode : hbNodes) {
                newNode.child.add(hbNode);
                current.child.remove(hbNode);
            }
            current.child.add(newNode);
            return true;
        } else {
            // Recursively check each child node for insertion
            for (Node node : current.child) {
                if (insert(node, newNode)) return true;
            }
            throw new IllegalStateException("Unreachable code - new node could not be inserted.");
        }

    }


    @Override
    public List<Node> searchDeps(Node n) {
        if (!exists(n)) throw new IllegalArgumentException("node n doesn't exists");
        List<Node> res = new ArrayList<>();
        searchDeps(root, n, res);
        return res;
    }

    private void searchDeps(Node current, Node n, List<Node> res) {
        for (Node child : current.child) {
            searchDeps(child, n, res);
        }
        if (n.compareTo(current) > 0 && current != root) {
            res.add(current);
        }
    }

    public boolean exists(Node n) {
        return exists(root, n);
    }

    private boolean exists(Node current, Node n) {
        if (Objects.equals(current, n)) return true;
        for (Node child : current.child) {
            if (exists(child, n)) return true;
        }
        return false;
    }

}