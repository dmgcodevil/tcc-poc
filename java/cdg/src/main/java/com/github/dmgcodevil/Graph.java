package com.github.dmgcodevil;

import java.util.List;

/**
 * Represents a causal dependency graph.
 */
public interface Graph {

    /**
     * Inserts a node into the causal dependency graph.
     *
     * @param n the node to insert
     */
    void insert(Node n);

    /**
     * Returns a list of nodes that happened before the given node 'n' in the causal dependency graph.
     *
     * @param n the node to search for dependencies
     * @return a list of nodes that happened before the given node 'n'
     * in the causal dependency graph
     */
    List<Node> searchDeps(Node n);
}