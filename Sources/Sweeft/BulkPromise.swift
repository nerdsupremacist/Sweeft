//
//  BulkPromise.swift
//  Pods
//
//  Created by Mathias Quintero on 12/29/16.
//
//

import Foundation

/// A promise that represent a collection of other promises and waits for them all to be finished
public class BulkPromise<T, O: Error>: Promise<[T], O> {
    
    let promises: [Promise<T, O>]
    var results: [(Int, T)] {
        didSet {
            if results.count == promises.count {
                success(with: results.sorted { $0.0 < $1.0 } => lastArgument)
            }
        }
    }
    
    init(promises: [Promise<T,O>], completionQueue: DispatchQueue = .main) {
        self.promises = promises
        results = []
        super.init(completionQueue: completionQueue)
        self.promises => { promise, index in
            promise.nest(to: self) { result, _ in
                self.results.append((index, result))
            }
        }
    }
    
}

extension BulkPromise where T: Collection {
    
    var flattened: Promise<[T.Iterator.Element], O> {
        return nested { result in
            return result.flatMap(id)
        }
    }
    
}
