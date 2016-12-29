//
//  Promise.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

public protocol PromiseBody {
    associatedtype Result
    associatedtype ErrorType: Error
    func onSuccess<O>(call handler: @escaping (Result) -> (O)) -> PromiseSuccessHandler<O, Result, ErrorType>
    func onError<O>(call handler: @escaping (ErrorType) -> (O)) -> PromiseErrorHandler<O, Result, ErrorType>
}

/// Promise Structs to prevent you from nesting callbacks over and over again
public class Promise<T, E: Error>: PromiseBody {
    
    /// Type of the success
    typealias SuccessHandler = (T) -> ()
    /// Type of the success
    typealias ErrorHandler = (E) -> ()
    
    /// All the handlers
    var successHandlers = [SuccessHandler]()
    var errorHandlers = [ErrorHandler]()
    let completionQueue: DispatchQueue
    
    /// Initializer
    public init(completionQueue: DispatchQueue = .main) {
        self.completionQueue = completionQueue
    }
    
    /**
     Add success handler
     
     - Parameter handler: function that should be called
     
     - Returns: PromiseHandler Object
     */
    @discardableResult public func onSuccess<O>(call handler: @escaping (T) -> (O)) -> PromiseSuccessHandler<O, T, E> {
        return PromiseSuccessHandler<O, T, E>(promise: self, handler: handler)
    }
    
    /// Add an error Handler
    @discardableResult public func onError<O>(call handler: @escaping (E) -> (O)) -> PromiseErrorHandler<O, T, E> {
        return PromiseErrorHandler<O, T, E>(promise: self, handler: handler)
    }
    
    /// Call this when the promise is fulfilled
    public func success(with value: T) {
        completionQueue >>> {
            self.successHandlers => { value | $0 }
        }
    }
    
    /// Call this when the promise has an error
    public func error(with value: E) {
        completionQueue >>> {
            self.errorHandlers => { value | $0 }
        }
    }
    
    /// Will create a Promise that is based on this promise but maps the result
    public func nested<V>(_ mapper: @escaping (T) -> V) -> Promise<V, E> {
        let promise = Promise<V, E>(completionQueue: completionQueue)
        onSuccess(call: mapper >>> promise.success)
        onError(call: promise.error)
        return promise
    }
    
    /// Will create a Promise that is based on this promise but maps the result
    public func nested<V>(_ mapper: @escaping (T, Promise<V, E>) -> ()) -> Promise<V, E> {
        let promise = Promise<V, E>(completionQueue: completionQueue)
        onSuccess {
            mapper($0, promise)
        }
        onError(call: promise.error)
        return promise
    }
    
}
