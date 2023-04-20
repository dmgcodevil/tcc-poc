package com.github.dmgcodevil;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

public class GraphStorage {

    private final BlockManger blockManger = new BlockManger();
    public static final int LONG_SIZE = 8;

    public static class Block {
        final long start_pos;
        final int size;
        final byte[] data;

        Block(long start_pos, int size) {
            this.start_pos = start_pos;
            this.size = size;
            this.data = new byte[size];
        }
    }

    public static class BlockManger {
        SortedMap<Long, Block> blocks = new TreeMap<>();

        Block allocate(int size) {
            long start_pos = lastBlockEnd() + 1L;
            Block block = new Block(start_pos, size);
            blocks.put(start_pos, block);
            return block;
        }

        Block first() {
            return blocks.get(blocks.firstKey());
        }

        long lastBlockEnd() {
            if (blocks.isEmpty()) return 0;
            Block block = blocks.get(blocks.lastKey());
            return block.start_pos + block.size;
        }
    }

    public Block getBlock(long pos) {
        return blockManger.blocks.get(pos);
    }

    // writes the node including its child
    public long write(Node n) {
        ByteBuffer buffer = encode(n);
        int size = buffer.position() + n.child.size() * LONG_SIZE;
        Block block = blockManger.allocate(size);
        for (Node child : n.child) {
            long child_pos = write(child);
            buffer.putLong(child_pos - block.start_pos);
        }
        buffer.flip();
        buffer.get(block.data);
        return block.start_pos;
    }

    // reads a node from the given block with its childs
    public Node read(Block block) {
        ByteBuffer buffer = ByteBuffer.wrap(block.data);
        int id_len = buffer.getInt();
        byte[] id_bytes = new byte[id_len];
        buffer.get(id_bytes);
        int vc_len = buffer.getInt();
        int[] vc = new int[vc_len];
        for (int i = 0; i < vc_len; i++) {
            vc[i] = buffer.getInt();
        }
        int child_len = buffer.getInt();
        List<Node> child = new ArrayList<>(child_len);
        for (int i = 0; i < child_len; i++) {
            long child_offset = buffer.getLong();
            long child_start_pos = block.start_pos + child_offset;
            child.add(read(blockManger.blocks.get(child_start_pos)));
        }
        return new Node(new String(id_bytes), vc, child);
    }

    private static ByteBuffer encode(Node node) {
        ByteBuffer buffer = ByteBuffer.allocate(1000);
        buffer.putInt(node.id.length());
        buffer.put(node.id.getBytes());
        buffer.putInt(node.vector_clock.length);
        for (int i : node.vector_clock) {
            buffer.putInt(i);
        }
        buffer.putInt(node.child.size());
        // we don't write offsets here we just allocate some space
        return buffer;
    }

}
