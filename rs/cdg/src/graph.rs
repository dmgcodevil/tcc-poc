use std::cell::RefCell;
use std::cmp::Ordering;
use std::ops::DerefMut;
use std::rc::Rc;

use crate::node::Node;

// Represents a causal dependency graph
pub struct Graph {
    root: Rc<RefCell<Node>>,
}

impl Graph {
    pub fn new(vector_size: usize) -> Self {
        let root = Rc::new(RefCell::new(
            Node::new("root", vec![0; vector_size])));
        Graph { root }
    }

    pub fn insert(&mut self, n: Node) -> bool {
        if self.exists(&n) {
            panic!("node already exists");
        }
        return Graph::insert_rec(self.root.borrow_mut().deref_mut(), n);
    }

    fn insert_rec(current: &mut Node, mut new_node: Node) -> bool {
        if current.get_child().is_empty() {
            current.add_child(new_node.clone());
            return true;
        }

        let hb_nodes: Vec<Node> = current
            .get_child_mut()
            .iter_mut()
            .filter(|child| new_node.cmp(child) > Ordering::Equal)
            .map(|child| child.clone())
            .collect();

        if !hb_nodes.is_empty() {
            for hb_node in hb_nodes {
                current.remove_child(&hb_node);
                new_node.add_child(hb_node);
            }
            current.add_child(new_node.clone());
            return true;
        } else {
            for node in current.get_child_mut().iter_mut() {
                if Graph::insert_rec(node, new_node.clone()) {
                    return true;
                }
            }
            panic!("Unreachable code - new node could not be inserted.");
        }
    }
    pub fn search_deps(&self, n: &Node) -> Vec<Node> {
        if !self.exists(n) {
            panic!("node n doesn't exist");
        }

        let mut res = Vec::<Node>::new();
        self.search_deps_recursive(&self.root.borrow(), n, &mut res);
        res
    }

    fn search_deps_recursive(&self, current: &Node, n: &Node, res: &mut Vec<Node>) {
        for child in current.get_child() {
            self.search_deps_recursive(child, n, res);
        }

        if n.cmp(current) > Ordering::Equal && current != &*self.root.borrow() {
            res.push(current.clone());
        }
    }

    pub fn exists(&self, n: &Node) -> bool {
        self.exists_rec(&self.root.borrow(), n)
    }

    fn exists_rec(&self, current: &Node, n: &Node) -> bool {
        if current == n {
            return true;
        }

        for child in current.get_child() {
            if self.exists_rec(child, n) {
                return true;
            }
        }

        false
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_insert_and_search_deps() {
        let mut graph = Graph::new(2);

        // create nodes
        let n1 = Node::new("1", vec![1, 0]);
        let n2 = Node::new("2", vec![2, 1]);
        let n3 = Node::new("3", vec![2, 2]);
        let n4 = Node::new("4", vec![3, 3]);
        let n5 = Node::new("5", vec![1, 1]);

        // insert nodes
        assert!(graph.insert(n1.clone()));
        assert!(graph.insert(n2.clone()));
        assert!(graph.insert(n3.clone()));
        assert!(graph.insert(n4.clone()));
        assert!(graph.insert(n5.clone()));

        // search for dependencies
        let deps1 = graph.search_deps(&n1);
        let deps2 = graph.search_deps(&n2);
        let deps3 = graph.search_deps(&n3);
        let deps4 = graph.search_deps(&n4);
        let deps5 = graph.search_deps(&n5);

        // assert dependencies
        assert_eq!(Vec::<Node>::new(), deps1);
        assert_eq!(vec![n1.clone(), n5.clone()], deps2);
        assert_eq!(vec![n1.clone(), n5.clone(), n2.clone()], deps3);
        assert_eq!(vec![n1.clone(), n5.clone(), n2.clone(), n3.clone()], deps4);
        assert_eq!(vec![n1.clone()], deps5);
    }

    #[test]
    #[should_panic(expected = "node already exists")]
    fn test_insert_with_duplicate_node() {
        let mut graph = Graph::new(2);

        // create nodes
        let n1 = Node::new("1", vec![1, 0]);

        // insert node twice
        assert!(graph.insert(n1.clone()));
        assert!(graph.insert(n1.clone()));
    }

    #[test]
    #[should_panic(expected = "node n doesn't exist")]
    fn test_search_deps_with_unknown_node() {
        let mut graph = Graph::new(2);

        // create nodes
        let n1 = Node::new("1", vec![1, 0]);
        let n2 = Node::new("2", vec![2, 1]);

        // insert nodes
        assert!(graph.insert(n1.clone()));

        // search for dependencies of an unknown node
        graph.search_deps(&n2);
    }
}
