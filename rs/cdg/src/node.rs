use std::cmp::Ordering;
use std::fmt;
use std::vec::Vec;

#[derive(Debug, Eq, PartialOrd)]
pub struct Node<'a> {
    id: &'a str,
    vector_clock: Vec<i32>,
    child: Vec<Node<'a>>,
}

impl<'a> Node<'a> {
    pub fn new(id: &'a str, vector_clock: Vec<i32>) -> Self {
        Self {
            id,
            vector_clock,
            child: vec![],
        }
    }
    pub fn get_id(&self) -> &str {
        return self.id;
    }
    pub fn add_child(&mut self, child: Node<'a>) {
        self.child.push(child);
    }
}

impl PartialEq for Node<'_> {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id && self.cmp(other) == Ordering::Equal
    }
}

impl Ord for Node<'_> {
    fn cmp(&self, other: &Self) -> Ordering {
        for i in 0..self.vector_clock.len() {
            if self.vector_clock[i] < other.vector_clock[i] {
                return Ordering::Less;
            } else if self.vector_clock[i] > other.vector_clock[i] {
                return Ordering::Greater;
            }
        }
        Ordering::Equal
    }
}

impl fmt::Display for Node<'_> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let ids = self.child.iter().map(|c| c.id).collect::<Vec<&str>>().join(",");
        write!(
            f,
            "Node{{id: '{}', vector_clock: {:?}, child: [{}]}}",
            self.id, self.vector_clock, ids
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new() {
        let node = Node::new("id", vec![0, 0]);
        assert_eq!(node.id, "id");
        assert_eq!(node.vector_clock, vec![0, 0]);
        assert!(node.child.is_empty());
    }

    #[test]
    fn test_add_child() {
        let mut parent = Node::new("parent", vec![0, 0]);
        let child = Node::new("child", vec![0, 1]);
        parent.add_child(child);
        assert_eq!(parent.child.len(), 1);
        assert_eq!(parent.child[0].id, "child");
    }

    #[test]
    fn test_eq() {
        let node1 = Node::new("id1", vec![0, 0]);
        let node2 = Node::new("id2", vec![0, 0]);
        assert_ne!(node1, node2);

        let node3 = Node::new("id", vec![1, 0]);
        let node4 = Node::new("id", vec![0, 1]);
        assert!(node3 > node4);

        let node5 = Node::new("id", vec![0, 1]);
        let node6 = Node::new("id", vec![0, 1]);
        assert_eq!(node5, node6);
    }

    #[test]
    fn test_cmp() {
        let node1 = Node::new("id1", vec![0, 0]);
        let node2 = Node::new("id2", vec![0, 1]);
        let node3 = Node::new("id1", vec![1, 0]);
        let node4 = Node::new("id1", vec![1, 1]);
        assert_eq!(node1.cmp(&node2), Ordering::Less);
        assert_eq!(node2.cmp(&node1), Ordering::Greater);
        assert_eq!(node1.cmp(&node3), Ordering::Less);
        assert_eq!(node3.cmp(&node1), Ordering::Greater);
        assert_eq!(node3.cmp(&node4), Ordering::Less);
        assert_eq!(node4.cmp(&node3), Ordering::Greater);
    }

    #[test]
    fn test_display() {
        let node1 = Node::new("id", vec![0, 0]);
        assert_eq!(
            format!("{}", node1),
            "Node{id: 'id', vector_clock: [0, 0], child: []}"
        );

        let mut node2 = Node::new("id", vec![0, 0]);
        let node3 = Node::new("3", vec![0, 1]);
        node2.add_child(node3);
        assert_eq!(
            format!("{}", node2),
            "Node{id: 'id', vector_clock: [0, 0], child: [3]}"
        );
    }
}
