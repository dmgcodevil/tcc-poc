# distributed-computing

Transactional Causal Consistency (TCC) system 

## Prerequisites / Knowledge base 

### Partial order

In mathematics, a partial order is a binary relation that is reflexive, antisymmetric, and transitive.

More specifically, a binary relation R on a set S is a partial order if it satisfies the following three properties for any elements a, b, and c in S:

1. Reflexivity: a R a for all a in S.
2. Antisymmetry: If a R b and b R a, then a = b.
3. Transitivity: If a R b and b R c, then a R c.


Intuitively, a partial order defines a kind of ordering or hierarchy among the elements in S, but this ordering may not be total. In other words, some pairs of elements in S may not be comparable under the partial order. For example, in a partial order of people based on height, two people of the same height may not be comparable, since neither is strictly taller than the other.

In the context of distributed systems or computer networks, partial orders are often used to represent the ordering of events across multiple processes or systems. Each event can be represented as an element in S, and the partial order relation can be used to capture the ordering constraints between events.


> Causality can be determined by projecting all the events onto a single time axis, but this will introduce orderings that are not necessarily in the partial order

Let's consider a simple distributed system with two processes, P1 and P2, and assume that events can occur in each process. Let's also assume that P1 sends a message to P2 at time t1, and P2 receives the message at time t2. Finally, let's assume that P1 also sends another message to P2 at time t3, and P2 receives the second message at time t4.

In this scenario, there are four events:

* Event e1: P1 sends message 1 at time t1.
* Event e2: P2 receives message 1 at time t2.
* Event e3: P1 sends message 2 at time t3.
* Event e4: P2 receives message 2 at time t4.

We can represent the causal relationships between these events using a partial order, where each event is an element in the set and the relation between events is given by the "happens-before" relation. For example, we know that e1 ≺ e2 and e3 ≺ e4.

If we project all the events onto a single time axis, we might get the following timeline:

```
t1	t2	t3	t4
e1	e2	e3	e4
```

This timeline introduces an ordering between all pairs of events, but not all of these orderings are necessarily in the partial order. For example, in the timeline above, e1 and e3 are ordered in a way that is not reflected in the partial order. Specifically, e1 appears to happen before e3, even though there is no causal relationship between them.

Thus, while projecting all events onto a single time axis can help us understand the relative ordering of events, it may introduce orderings that are not part of the partial order, and therefore not reflective of the true causal relationships between events in the distributed system.

### Linear extension

In mathematics, a linear extension of a partial order is a way to extend the partial order to a total order. More specifically, a linear extension of a partial order (E, ≺) is a linear ordering of the elements in E that preserves the order relations in ≺.

To understand this definition, let's consider an example. Suppose we have a partial order on the set of integers given by the relation "divides" (i.e., x ≺ y if x divides y). The partial order looks like this:

```
4 --- 8
  \   |
   \  |
    \ |
     \|
      16

```

In this partial order, 4 divides 8, 4 divides 16, and 8 divides 16. However, 4 and 8 are not comparable, and neither are 8 and 16.

Now, let's say we want to extend this partial order to a total order. One way to do this is to choose a linear extension of the partial order, which is a way to "stretch out" the partial order into a linear ordering that includes all the elements. One possible linear extension is:

```
4 < 8 < 16
```

his linear extension preserves the order relations in the partial order, since 4 comes before 8 and 8 comes before 16, which is consistent with the "divides" relation. Note that there are other possible linear extensions of this partial order, such as:


`8 < 4 < 16`

However, this linear extension is not consistent with the "divides" relation, since it places 4 before 8 even though 4 divides 8.

In summary, a linear extension of a partial order is a way to extend the partial order to a total order while preserving the order relations in the partial order. This concept is often used in the context of distributed systems or computer networks, where partial orders are used to represent the ordering of events across multiple processes or systems.

Example:

Consider the following partial order on events {a, b, c, d}:

a precedes b and c
b and c both precede d
One possible linear extension consistent with this partial order is: a, b, c, d.

Another possible linear extension is: a, c, b, d.

Both of these linear extensions are consistent with the original partial order, as they preserve the causal relationships between the events. But they represent different linear orderings of the events on the time axis, and may imply different causality relationships between the events.

merge the linear extensions A = [a, b, c, d] and B = [a, c, b, d] into a single set of tuples that represents the original partial order. Here is a simple algorithm to merge two linear extensions:

Initialize an empty set M to store the merged tuples.
Compare the first elements of the two linear extensions. If they are equal, add the corresponding tuple to M and remove the elements from both linear extensions.
If the first element of A precedes the first element of B in the original partial order, add the corresponding tuple to M and remove the element from A.
If the first element of B precedes the first element of A in the original partial order, add the corresponding tuple to M and remove the element from B.
Repeat steps 2-4 until one of the linear extensions is empty.
Add any remaining tuples from the non-empty linear extension to M.
Using this algorithm, we can merge the linear extensions A and B as follows:

Initialize an empty set M: M = {}
Compare the first elements of A and B: a = a, add (a, a) to M and remove a from both A and B.
Compare the first elements of A and B: b < c, add (a, b) to M and remove b from A.
Compare the first elements of B and A: c < b, add (a, c) to M and remove c from B.
Compare the first elements of A and B: c = c, add (c, c) to M and remove c from both A and B.
Compare the first elements of A and B: b < d, add (c, b) to M and remove b from A.
Compare the first elements of B and A: b < d, add (b, d) to M and remove b and d from B.
Add the remaining element of A to M: add (d, d) to M and remove d from A.
Merged tuples: `M = {(a, a), (a, b), (a, c), (b, d), (c, b), (c, c), (d, d)}`
The set of merged tuples M represents the original partial order.


**Lamport's scalar clock** rules are a set of rules that define how to update a logical clock based on events that occur in a distributed system. The rules are:

* Initialization: Each process has a clock that is initially set to zero.
* Event increment: Each time an event occurs at a process, its clock is incremented by one.
* Send timestamping: When a process sends a message, it includes its current clock value in the message.
* Receive timestamping: When a process receives a message, it sets its clock to the maximum of its current clock value and the timestamp in the received message, and then increments its clock by one.

These rules ensure that the logical clocks of different processes are monotonically increasing and that causally related events have consistent ordering across the distributed system. However, they do not guarantee that non-causal events have a consistent ordering.


### Transactional Causal Consistency (TCC)

Main components:

1. Function Executors: The compute nodes responsible for executing the client-defined functions.
2. Transaction Coordinator Service: The central service responsible for coordinating and managing the transaction lifecycle, including validation, pre-write, commit, and abort.
3. Causal Consistency Checker: The service responsible for checking the causal consistency of the transaction before it is committed.
4. Dependency Graph Storage: The persistent storage system that stores the dependency graph for each transaction.
5. Client Application: The application that interacts with the TCC system to perform business operations and define custom functions.

These components work together to provide transactional causal consistency for serverless computing.

### Dependency graph shapshots/checkpoints

Checkpointing can be used to reduce the size of event dependency graph on every function executor. Checkpointing involves periodically taking a snapshot of the state of the system and storing it in a durable storage. This can be done at regular intervals or based on the size of the dependency graph.

Once a checkpoint is taken, any events that have already been processed can be removed from the dependency graph, and only the events after the checkpoint need to be retained. This reduces the size of the dependency graph and the amount of data that needs to be stored and transmitted between the function executors and the TCC.

However, checkpointing introduces additional overhead as it involves taking snapshots of the state of the system, which can be a time-consuming process. Therefore, the frequency of checkpoints should be balanced between reducing the size of the dependency graph and minimizing the overhead of checkpointing.


To implement a Transaction Coordinator Service (TCS), the following are needed:

1. A distributed database or key-value store: This is needed to store the metadata related to transactions and events such as transaction ID, event ID, event type, event payload, timestamp, and the causal dependencies between events.
2. A messaging system: This is needed for communication between the TCS and function executors. The messaging system should support reliable delivery, ordering, and at-least-once semantics.
3. A Causal Consistency Checker: This is a component that determines the causal dependencies between events by analyzing their metadata. It needs to be highly available and scalable since it will be used by every function executor.
4. Function executors: These are the compute nodes that execute the functions submitted by the clients. They need to be able to retrieve the causal dependencies for the events they process, so they can ensure causal consistency.
5. Client libraries: These are libraries or SDKs that the clients can use to interact with the TCS. They should provide an easy-to-use interface for submitting events and transactions and also handle the retry logic in case of failures.
6. Rollback handlers: These are functions that handle the rollback logic in case of transaction failures. They need to be provided by the clients since they have the most knowledge about the underlying data store.
7. Monitoring and alerting: This is needed to monitor the health of the system and alert the operators in case of failures or anomalies.


### causal dependency graph (draft)

```
class GraphImpl implements Graph:
    root: Node
    vectorSize: int

    GraphImpl(vectorSize: int):
        this.vectorSize = vectorSize
        this.root = Node("root", new int[vectorSize])

    insert(n: Node) -> void:
        if exists(n) then throw IllegalArgumentException("node already exists in the graph")
        insert(root, n)

    insert(current: Node, newNode: Node) -> bool:
        if current.child.isEmpty() then
            current.child.add(newNode)
            return true
        hbNodes = current.child.stream()
                  .filter(child -> newNode.compareTo(child) > 0)
                  .collect(Collectors.toList())
        if not hbNodes.isEmpty() then
            for hbNode in hbNodes do
                newNode.child.add(hbNode)
                current.child.remove(hbNode)
            current.child.add(newNode)
            return true
        else:
            for node in current.child do
                if insert(node, newNode) then return true
            throw IllegalStateException("Unreachable code - new node could not be inserted.")

    searchDeps(n: Node) -> List<Node>:
        if not exists(n) then throw IllegalArgumentException("node n doesn't exist")
        res = new ArrayList<Node>()
        searchDeps(root, n, res)
        return res

    searchDeps(current: Node, n: Node, res: List<Node>) -> void:
        for child in current.child do
            searchDeps(child, n, res)
        if n.compareTo(current) > 0 and current != root then
            res.add(current)

    exists(n: Node) -> bool:
        return exists(root, n)

    exists(current: Node, n: Node) -> bool:
        if current == n then return true
        for child in current.child do
            if exists(child, n) then return true
        return false

```

Explanation:


1. `insert(Node n)`: This method is used to insert a new node into the DAG. If the node already exists in the graph, an exception is thrown. The method first checks if the current node has any child nodes. If not, it adds the new node as the first child of the current node. Otherwise, it finds all child nodes that happened before the new node (i.e., all nodes that have a causal relationship with the new node), moves them under the new node, and then adds the new node as a child of the current node.

2. `searchDeps(Node n)`: This method is used to search for all nodes in the graph that are causally dependent on a given node n. If n does not exist in the graph, an exception is thrown. The method recursively traverses the graph and adds all nodes that are causally dependent on n to a list res.

3. `exists(Node n)`: This method is used to check if a given node n exists in the graph. The method recursively traverses the graph and returns true if the node is found, and false otherwise.


### Snapshot Construction / Causal snapshot reads  

In the context of TCC, the creation of a snapshot typically occurs when a function is invoked to process an event. The purpose of creating a snapshot is to capture the relevant set of events that are causally related to the event being processed.

When a function is triggered to handle an event, it examines the causal dependencies associated with that event. It constructs a snapshot by including all the events that causally precede the current event or have a causal relationship with it. This snapshot serves as the reference point for maintaining causal consistency during the execution of the function.

The function uses this snapshot to ensure that it has access to all the necessary information and dependencies required to process the event correctly. It can then perform any required operations, such as reading data, applying transformations, or generating new events, based on the information available within the snapshot.

By creating a snapshot specific to each event being processed, the function guarantees that it considers the relevant events within its causal context. This enables it to maintain the desired causal consistency and order of event processing.




