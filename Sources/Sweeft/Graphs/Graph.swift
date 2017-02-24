//
//  Graph.swift
//  Pods
//
//  Created by Mathias Quintero on 2/22/17.
//


import Foundation

public class Graph<Node: GraphNode>: NodeProvider {
    
    public typealias Identifier = Node.Identifier
    
    let nodes: [Identifier : Node]
    
    init(from nodes: [Node] = .empty) {
        self.nodes = nodes >>= { ($0.identifier, $0) }
    }
    
    public func node(for identifier: Identifier) -> Node? {
        return self.nodes[identifier]
    }
    
}

struct QueueEntry<T: GraphNode>: Hashable {
    
    public var hashValue: Int {
        return item.identifier.hashValue
    }

    let item: T
    
    public static func ==(lhs: QueueEntry<T>, rhs: QueueEntry<T>) -> Bool {
        return lhs.item.identifier == rhs.item.identifier
    }
    
}

extension Graph {
    
//    public func shortestPath(from source: Identifier, to destination: Identifier) -> [Identifier]? {
//        guard let source = node(for: source) else {
//            return nil
//        }
//        return shortestPath(from: source) { $0 == destination }
//    }
    
    private func computePath<V>(using prevs: [V:V], until last: V) -> [V] {
        if let prev = prevs[last] {
            return [last] + computePath(using: prevs, until: prev)
        } else {
            return [last]
        }
    }
    
    func iterate(queue: PriorityQueue<QueueEntry<Node>, Double>,
                 prevs: [Identifier : Identifier],
                 costs: [Identifier : Double],
                 source: Identifier,
                 euristic: @escaping (Identifier) -> Double,
                 isFinal: @escaping (Identifier) -> Bool) -> ResultPromise<[Identifier]?> {
        
        var costs = costs
        var prevs = prevs
        
        let promise = Promise<[Identifier]?, AnyError>()
        if let current = queue.pop()?.item {
            print(prevs)
            if isFinal(current.identifier) {
                promise.success(with: <>computePath(using: prevs, until: current.identifier))
            } else {
                let cost = costs[current.identifier].?
                current.neighbours(in: self).onSuccess { neighbours in
                    neighbours => { item in
                        let entry = QueueEntry(item: item.0)
                        let estimate = cost + item.1 + euristic(item.0.identifier)
                        if let priority = queue.priority(for: entry) {
                            if estimate < priority {
                                queue.update(entry, with: estimate)
                                prevs[item.0.identifier] = current.identifier
                                costs[item.0.identifier] = cost + item.1
                            }
                        } else if prevs[item.0.identifier] == nil, source != item.0.identifier {
                            queue.add(entry, with: estimate)
                            prevs[item.0.identifier] = current.identifier
                            costs[item.0.identifier] = cost + item.1
                        }
                    }
                    self.iterate(queue: queue, prevs: prevs, costs: costs,
                                 source: source, euristic: euristic, isFinal: isFinal).nest(to: promise, using: id)
                }
                .onError { _ in
                    self.iterate(queue: queue, prevs: prevs, costs: costs,
                                 source: source, euristic: euristic, isFinal: isFinal).nest(to: promise, using: id)
                }
            }
        } else {
            promise.success(with: nil)
        }
        return promise
    }
    
    public func shortestPath(from source: Node,
                             with euristic: @escaping (Identifier) -> Double = **{ 0 },
                             until isFinal: @escaping (Identifier) -> Bool) -> ResultPromise<[Identifier]?> {
        
        let queue = PriorityQueue<QueueEntry<Node>, Double>()
        queue.add(QueueEntry(item: source), with: 0)
        
        return iterate(queue: queue, prevs: .empty, costs: .empty,
                       source: source.identifier, euristic: euristic, isFinal: isFinal)
    }
    
}
