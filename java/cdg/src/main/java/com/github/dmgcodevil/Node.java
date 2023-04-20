package com.github.dmgcodevil;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Represents a node in a causal dependency graph.
 */
public class Node implements Comparable<Node> {

    /**
     * Creates a new Node object with the given ID and vector clock.
     *
     * @param id           the unique identifier of the node
     * @param vector_clock an array representing the vector clock of the node
     */
    public Node(String id, int[] vector_clock) {
        this(id, vector_clock, new ArrayList<>());
    }

    public Node(String id, int[] vector_clock,List<Node>child) {
        this.id = id;
        this.vector_clock = vector_clock;
        this.child = child;
    }

    /**
     * The unique identifier of this node.
     */
    final String id;

    /**
     * An array representing the vector clock of this node.
     */
    final int[] vector_clock;

    /**
     * The child nodes of this node.
     */
    final List<Node> child;

    /**
     * Compares this node to another node based on their vector clocks.
     *
     * @param that the other node to compare to
     * @return -1 if this node happens before that, 1 if that node happens before this, 0 if they are concurrent
     */
    @Override
    public int compareTo(Node that) {
        for (int i = 0; i < vector_clock.length; i++) {
            if (vector_clock[i] < that.vector_clock[i]) return -1;
            if (vector_clock[i] > that.vector_clock[i]) return 1;
        }
        return 0;
    }

    /**
     * Checks whether this node is equal to another node.
     *
     * @param o the other object to compare to
     * @return true if this node is equal to the other node, false otherwise
     */
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Node node = (Node) o;

        return id.equals(node.id) && compareTo(node) == 0;
    }

    /**
     * Computes the hash code of this node.
     *
     * @return the hash code of this node
     */
    @Override
    public int hashCode() {
        return id.hashCode();
    }

    @Override
    public String toString() {
        return "Node{" +
                "id='" + id + '\'' +
                ", vector_clock=" + Arrays.toString(vector_clock) +
                ", child=" + child +
                '}';
    }
}

