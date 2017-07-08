//
//  TryBulkPromise.swift
//  MyTV
//
//  Created by Mathias Quintero on 6/19/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Sweeft

class FailableBulkPromise<V, R, E: Error>: Promise<R, E> {
    
    let inputs: [V]
    let transform: (V) -> Promise<R, E>
    
    private var lastError: E?
    
    private var current = 0
    
    init(inputs: [V], transform: @escaping (V) -> Promise<R, E>) {
        self.inputs = inputs
        self.transform = transform
        super.init()
        doit()
    }
    
    func doit() {
        guard current < inputs.count else {
            if let lastError = lastError {
                error(with: lastError)
            }
            return
        }
        let input = inputs[current]
        let promise = transform(input)
        promise.onSuccess(call: self.handleValue).onError(call: self.handleError)
    }
    
    func handleValue(with output: R) {
        success(with: output)
    }
    
    func handleError(with error: E) {
        lastError = error
        current += 1
        doit()
    }
    
    func `continue`() -> FailableBulkPromise<V, R, E> {
        let inputs = self.inputs.array(from: current)
        return FailableBulkPromise(inputs: inputs, transform: transform)
    }
    
}
