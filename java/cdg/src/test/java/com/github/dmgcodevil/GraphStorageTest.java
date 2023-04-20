package com.github.dmgcodevil;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class GraphStorageTest {

    @Test
    public void testWriteRead() {
        GraphStorage graphStorage = new GraphStorage();
        Node node1 = new Node("1", new int[]{1, 0});
        Node node2 = new Node("2", new int[]{2, 0});
        node2.child.add(node1);
        long node2Pos = graphStorage.write(node2);
        Node actualNode2 = graphStorage.read(graphStorage.getBlock(node2Pos));
        assertEquals(node2, actualNode2);
        assertEquals(1, node2.child.size());
        assertEquals(node1, actualNode2.child.get(0));
    }
}
