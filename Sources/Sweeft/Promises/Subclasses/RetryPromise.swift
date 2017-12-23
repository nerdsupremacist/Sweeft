//
//  RetryPromise.swift
//  Sweeft
//
//  Created by Mathias Quintero on 7/17/17.
//

import Foundation

public class RetryPromise<I, V, E: Error>: SelfSettingPromise<V, E> {
    
    public typealias Creator = () -> Promise<V, E>
    public typealias RetryHandler = (E?) -> ()
    public typealias RetryBehavior = (E, @escaping RetryHandler) -> ()
    
    let creator: Creator
    let retryBehavior: RetryBehavior
    var stopped = false
    var lastError: E?
    
    public init(creator: @escaping Creator, retryBehavior: @escaping RetryBehavior) {
        self.creator = creator
        self.retryBehavior = retryBehavior
        super.init()
        self.try()
    }
    
    func `try`() {
        let promise = creator()
        promise.onSuccess(call: self.setter.success)
        promise.onError(call: self.handle(error:))
    }
    
    func handle(error: E) {
        guard !stopped else { return }
        self.lastError = error
        retryBehavior(error) { error in
            if let error = error {
                self.setter.error(with: error)
            } else {
                self.try()
            }
        }
    }
    
    public func stop() {
        guard !stopped else { return }
        stopped = true
        if let error = lastError {
            self.setter.error(with: error)
        }
    }
    
}

extension RetryPromise {
    
    @available(macOS 10.12, *)
    static func new(retrying timeinterval: TimeInterval,
                    creator: @escaping Creator) -> RetryPromise<I, V, E> {
        
        return RetryPromise(creator: creator) { error, completion in
            Timer.scheduledTimer(withTimeInterval: timeinterval, repeats: false) { _ in
                completion(nil)
            }
        }
    }
    
}
