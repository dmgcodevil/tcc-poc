package com.github.dmgcodevil;

import org.junit.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.Assert.assertEquals;

public class GraphTest {

    @Test
    public void testInsertAndSearchDeps() {
        Graph graph = new GraphImpl(2);

        // create nodes
        Node n1 = new Node("1", new int[]{1, 0});
        Node n2 = new Node("2", new int[]{2, 1});
        Node n3 = new Node("3", new int[]{2, 2});
        Node n4 = new Node("4", new int[]{3, 3});
        Node n5 = new Node("5", new int[]{1, 1});

        // insert nodes
        graph.insert(n1);
        graph.insert(n2);
        graph.insert(n3);
        graph.insert(n4);
        graph.insert(n5);

        // search for dependencies
        List<Node> deps1 = graph.searchDeps(n1);
        List<Node> deps2 = graph.searchDeps(n2);
        List<Node> deps3 = graph.searchDeps(n3);
        List<Node> deps4 = graph.searchDeps(n4);
        List<Node> deps5 = graph.searchDeps(n5);

        // assert dependencies
        assertEquals(Collections.emptyList(), deps1);
        assertEquals(Arrays.asList(n1, n5), deps2);
        assertEquals(Arrays.asList(n1, n5, n2), deps3);
        assertEquals(Arrays.asList(n1, n5, n2, n3), deps4);
        assertEquals(List.of(n1), deps5);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSearchDepsWithUnknownNode() {
        Graph graph = new GraphImpl(2);

        // create nodes
        Node n1 = new Node("1", new int[]{1, 0});
        Node n2 = new Node("2", new int[]{2, 1});

        // insert nodes
        graph.insert(n1);

        // search for dependencies of an unknown node
        graph.searchDeps(n2);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testInsertWithDuplicateNode() {
        Graph graph = new GraphImpl(2);

        // create nodes
        Node n1 = new Node("1", new int[]{1, 0});

        // insert node twice
        graph.insert(n1);
        graph.insert(n1);
    }

}