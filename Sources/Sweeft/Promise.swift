//
//  Promise.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

/// Promise Structs to prevent you from nesting callbacks over and over again
public struct Promise<T, E: Error> {
    
    /// Type of the success
    typealias SuccessHandler = (T) -> ()
    /// Type of the success
    typealias ErrorHandler = (E) -> ()
    
    /// All the handlers
    private var successHandlers = [SuccessHandler]()
    private var errorHandlers = [ErrorHandler]()
    
    /// Add a success handler
    @discardableResult mutating func onSuccess(call handler: @escaping SuccessHandler) -> Promise {
        successHandlers.append(handler)
        return self
    }
    
    /// Add an error Handler
    @discardableResult mutating func onError(call handler: @escaping ErrorHandler) -> Promise {
        errorHandlers.append(handler)
        return self
    }
    
    /// Call this when the promise is fulfilled
    public func success(with value: T) {
        successHandlers => { value | $0 }
    }
    
    /// Call this when the promise has an error
    public func error(with value: E) {
        errorHandlers => { value | $0 }
    }
    
}
