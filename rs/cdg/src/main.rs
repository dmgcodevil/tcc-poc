use node::Node;
use graph::Graph;

mod node;
mod graph;

fn create_node() -> Node {
    let mut n1 = Node::new("1", vec![1, 0, 0]);
    let n2 = Node::new("2", vec![1, 1, 0]);
    n1.add_child(n2);
    n1
}

fn main() {
    let node1 = create_node();
    println!("{}", node1);
    let _g = Graph::new(10);

}
