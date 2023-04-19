# distributed-computing
distributed-computing knowledge base


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
