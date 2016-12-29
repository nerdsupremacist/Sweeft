//
//  BulkPromise.swift
//  Pods
//
//  Created by Mathias Quintero on 12/29/16.
//
//

import Foundation

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
            promise
                .onSuccess {
                    self.results.append((index, $0))
                }
                .onError(call: self.error)
        }
    }
    
}

extension BulkPromise where T: Collection {
    
    var flattened: Promise<[T.Iterator.Element], O> {
        let promise = Promise<[T.Iterator.Element], O>()
        self.onSuccess { result in
            promise.success(with: result.flatMap(id))
        }
        self.onError(call: promise.error)
        return promise
    }
    
}
