//
//  TryBulkPromise.swift
//  Sweeft
//
//  Created by Mathias Quintero on 6/19/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

public class FailableBulkPromise<R, E: Error>: SelfSettingPromise<R, E> {
    
    public typealias Factory = () -> Promise<R, E>
    
    private let factories: [Factory]
    private var lastError: E?
    private var current = 0
    
    public convenience init<V>(inputs: [V], transform: @escaping (V) -> Promise<R, E>) {
        self.init(factories: inputs => { input in { transform(input) } })
    }
    
    public init(factories: [Factory]) {
        self.factories = factories
        super.init()
        doit()
    }
    
    func doit() {
        guard current < factories.count else {
            if let lastError = lastError {
                setter.error(with: lastError)
            }
            return
        }
        let promise = factories[current]()
        promise.onSuccess(call: self.handleValue).onError(call: self.handleError)
    }
    
    func handleValue(with output: R) {
        setter.success(with: output)
    }
    
    func handleError(with error: E) {
        lastError = error
        current += 1
        doit()
    }
    
    public func `continue`() -> FailableBulkPromise<R, E> {
        let factories = self.factories.array(from: current)
        return FailableBulkPromise(factories: factories)
    }
    
}

public func ??<V, E>(_ lhs: @escaping @autoclosure () -> Promise<V, E>, _ rhs: @escaping @autoclosure () -> Promise<V, E>) -> FailableBulkPromise<V, E> {
    
    return FailableBulkPromise(factories: [lhs, rhs])
}
