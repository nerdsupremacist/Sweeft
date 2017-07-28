//
//  RetryPromise.swift
//  Sweeft
//
//  Created by Mathias Quintero on 7/17/17.
//

import Foundation

public class RetryPromise<I, V, E: Error>: Promise<V, E> {
    
    public typealias Creator = (I) -> Promise<V, E>
    public typealias RetryHandler = (E?) -> ()
    public typealias RetryBehavior = (E, @escaping RetryHandler) -> ()
    
    var input: I
    var creator: Creator
    var retryBehavior: (E, @escaping RetryHandler) -> ()
    var stopped = false
    var lastError: E?
    
    public init(input: I, creator: @escaping Creator, retryBehavior: @escaping RetryBehavior) {
        self.input = input
        self.creator = creator
        self.retryBehavior = retryBehavior
        super.init()
        self.try()
    }
    
    func `try`() {
        let promise = creator(input)
        promise.onSuccess(call: self.success)
        promise.onError(call: self.handle(error:))
    }
    
    func handle(error: E) {
        guard !stopped else { return }
        self.lastError = error
        retryBehavior(error) { error in
            if let error = error {
                self.error(with: error)
            } else {
                self.try()
            }
        }
    }
    
    public func stop() {
        guard !stopped else { return }
        stopped = true
        if let error = lastError {
            self.error(with: error)
        }
    }
    
}

extension RetryPromise {
    
    static func new(retrying timeinterval: TimeInterval, with input: I, creator: @escaping Creator) -> RetryPromise<I, V, E> {
        return RetryPromise(input: input, creator: creator) { error, completion in
            Timer.scheduledTimer(withTimeInterval: timeinterval, repeats: false) { _ in
                completion(nil)
            }
        }
    }
    
}
