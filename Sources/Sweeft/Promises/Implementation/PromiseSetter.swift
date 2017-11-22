//
//  PromiseSetter.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/22/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Foundation


extension Promise {
    
    public class Setter {
        fileprivate let promise: Promise<T, E>
        
        init(promise: Promise<T, E>) {
            self.promise = promise
        }
    }
    
}

extension Promise.Setter: PromiseSetterProtocol {
    
    public func weak() -> Weak {
        return Weak(promise: promise)
    }
    
    public func cancel() {
        promise.cancel()
    }
    
    /// Handle your promise being cancelled
    public func onCancel(call handler: @escaping () -> ()) {
        promise.onCancel(call: handler)
    }
    
    /// Call this when promise status is done
    public func write(result: Result<T, E>) {
        promise.write(result: result)
    }
    
}

extension Promise.Setter {
    
    public class Weak {
        
        fileprivate weak var promise: Promise<T, E>?
        
        fileprivate init(promise: Promise<T, E>) {
            self.promise = promise
        }
        
    }
    
}

extension Promise.Setter.Weak: PromiseSetterProtocol {
    
    public func cancel() {
        promise?.cancel()
    }
    
    /// Handle your promise being cancelled
    public func onCancel(call handler: @escaping () -> ()) {
        promise?.onCancel(call: handler)
    }
    
    /// Call this when promise status is done
    public func write(result: Result<T, E>) {
        promise?.write(result: result)
    }
    
    /// Call this when the promise is fulfilled
    public func success(with value: T) {
        write(result: .value(value))
    }
    
    /// Call this when the promise has an error
    public func error(with error: E) {
        write(result: .error(error))
    }
    
}

extension Promise {
    
    public class Canceller {
        
        fileprivate weak var promise: Promise<T, E>?
        
        fileprivate init(promise: Promise<T, E>) {
            self.promise = promise
        }
        
    }
    
    var canceller: Canceller {
        return .init(promise: self)
    }
    
}

extension Promise.Canceller {
    
    public func cancel() {
        promise?.cancel()
    }
    
}

