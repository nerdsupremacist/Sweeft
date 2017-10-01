//
//  BulkPromise.swift
//  Pods
//
//  Created by Mathias Quintero on 12/29/16.
//
//

import Foundation

/// A promise that represent a collection of other promises and waits for them all to be finished
public final class BulkPromise<T, O: Error>: SelfSettingPromise<[T], O> {
    
    private let count: Int
    private var results: [(Int, T)] = .empty {
        didSet {
            if results.count == count {
                let sorted = results.sorted(ascending: firstArgument) => lastArgument
                setter?.success(with: sorted)
            }
        }
    }
    
    public init(promises: [Promise<T,O>], completionQueue: DispatchQueue = .global()) {
        count = promises.count
        super.init(completionQueue: completionQueue)
        promises.withIndex => { promise, index in
            promise.onError(call: self.setter.error)
            promise.onSuccess { result in
                self.results.append((index, result))
            }
        }
        if promises.isEmpty {
            setter.success(with: [])
        }
    }
    
}

extension BulkPromise where T: Collection {
    
    public var flattened: Promise<[T.Element], O> {
        return map { result in
            return result.flatMap(id)
        }
    }
    
}

extension BulkPromise: ExpressibleByArrayLiteral {
    
    public convenience init(arrayLiteral elements: Promise<T, O>...) {
        self.init(promises: elements)
    }
    
}
