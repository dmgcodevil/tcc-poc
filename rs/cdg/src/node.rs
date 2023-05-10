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
        let ids: Vec<&str> = self.child.iter().map(|c| c.id).collect();
        write!(
            f,
            "Node{{id: '{}', vector_clock: {:?}, child: [{:?}]}}",
            self.id, self.vector_clock, ids
        )
    }
}
