//
//  Promise.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

public typealias ResultPromise<R> = Promise<R, AnyError>

enum PromiseState<T, E: Error> {
    case done(result: Result<T, E>)
    case waiting
    
    var isDone: Bool {
        guard case .done = self else {
            return false
        }
        return true
    }
    
    var result: Result<T, E>? {
        guard case .done(let result) = self else {
            return nil
        }
        return result
    }
    
    var value: T? {
        return result?.value
    }
    
    var error: E? {
        return result?.error
    }
}

public protocol PromiseBody {
    associatedtype ResultType
    associatedtype ErrorType: Error
    func onSuccess(call handler: @escaping (ResultType) -> ()) -> Promise<ResultType, ErrorType>
    func onError(call handler: @escaping (ErrorType) -> ()) -> Promise<ResultType, ErrorType>
    func nest<V>(to setter: Promise<V, ErrorType>.Setter, using mapper: @escaping (ResultType) -> (V))
    func nest<V>(to setter: Promise<V, ErrorType>.Setter, using mapper: @escaping (ResultType) -> ())
}

/// Promise Structs to prevent you from nesting callbacks over and over again
public class Promise<T, E: Error>: PromiseBody {
    /// Type of the success
    typealias SuccessHandler = (T) -> ()
    /// Type of the success
    typealias ErrorHandler = (E) -> ()
    // Result Type
    public typealias Result = Sweeft.Result<T, E>
    // Type of result handler
    public typealias ResultHandler = (Result) -> ()
    
    /// All the handlers
    var successHandlers = [SuccessHandler]()
    var errorHandlers = [ErrorHandler]()
    var resultHandlers = [ResultHandler]()
    
    var state: PromiseState<T, E> = .waiting
    
    let completionQueue: DispatchQueue
    
    /// Initializer
    public init(completionQueue: DispatchQueue = .global(), _ handle: (Setter) -> ()) {
        self.completionQueue = completionQueue
        handle(.init(promise: self))
    }
    
    public init(result: Result, completionQueue: DispatchQueue = .global()) {
        self.completionQueue = completionQueue
        self.state = .done(result: result)
    }
    
    public static func with(result: Result) -> Promise<T, E> {
        return Promise(result: result)
    }
    
    public static func successful(with value: T) -> Promise<T, E> {
        return .with(result: .value(value))
    }
    
    public static func errored(with value: E) -> Promise<T, E> {
        return .with(result: .error(value))
    }
    
    public static func new(completionQueue: DispatchQueue = .global(), _ handle: (Promise<T, E>.Setter) -> ()) -> Promise<T, E> {
        return Promise<T, E>(completionQueue: completionQueue, handle)
    }
    
    /**
     Add success handler
     
     - Parameter handler: function that should be called
     
     - Returns: PromiseHandler Object
     */
    @discardableResult public final func onSuccess(call handler: @escaping (T) -> ()) -> Promise<T, E> {
        if let result = state.value {
            completionQueue >>> handler ** result
        } else {
            successHandlers.append(handler)
        }
        return self
    }
    
    /// Add an error Handler
    @discardableResult public final func onError(call handler: @escaping (E) -> ()) -> Promise<T, E> {
        if let error = state.error {
            completionQueue >>> handler ** error
        } else {
            errorHandlers.append(handler)
        }
        return self
    }
    
    /// Add a
    @discardableResult public func onResult(call handler: @escaping ResultHandler) -> Promise<T, E> {
        if let result = state.result {
            completionQueue >>> handler ** result
        } else {
            resultHandlers.append(handler)
        }
        return self
    }
    
    /// Call this when the promise is fulfilled
    fileprivate func success(with value: T) {
        guard !state.isDone else {
            return
        }
        state = .done(result: .value(value))
        let handlers = successHandlers + (resultHandlers => calling)
        successHandlers = []
        errorHandlers = []
        resultHandlers = []
        completionQueue >>> {
            handlers => apply(value: value)
        }
    }
    
    /// Call this when the promise has an error
    fileprivate func error(with value: E) {
        guard !state.isDone else {
            return
        }
        state = .done(result: .error(value))
        let handlers = errorHandlers + (resultHandlers => calling)
        successHandlers = []
        errorHandlers = []
        resultHandlers = []
        completionQueue >>> {
            handlers => apply(value: value)
        }
    }
    
    /// Will nest a promise inside another one
    public func nest<V>(to setter: Promise<V, E>.Setter, using mapper: @escaping (T) -> (V)) {
        nest(to: setter, using: mapper >>> setter.success**)
    }
    
    /// Will nest a promise inside another one
    public func nest<V>(to setter: Promise<V, E>.Setter, using mapper: @escaping (T) -> ()) {
        onSuccess(call: mapper)
        onError(call: setter.error)
    }
    
    /// Will create a Promise that is based on this promise but maps the result
    public func map<V>(completionQueue: DispatchQueue = .global(),
                          _ mapper: @escaping (T) -> V) -> Promise<V, E> {
        
        return .new(completionQueue: completionQueue) { promise in
            self.nest(to: promise, using: mapper)
        }
    }
    
    public func flatMap<V>(completionQueue: DispatchQueue = .global(),
                        _ mapper: @escaping (T) -> Promise<V, E>) -> Promise<V, E> {
        
        return .new(completionQueue: completionQueue) { promise in
            map(mapper).onResult { result in
                switch result {
                case .value(let resultPromise):
                    resultPromise.nest(to: promise, using: id)
                case .error(let error):
                    promise.error(with: error)
                }
            }
        }
    }
    
    public func generalizeError(completionQueue: DispatchQueue = .global()) -> Promise<T, AnyError> {
        
        return .new(completionQueue: completionQueue) { promise in
            onSuccess(call: promise.success)
            onError(call: AnyError.error >>> promise.error)
        }
    }
    
    public func wait() -> Result {
        let group = DispatchGroup()
        var result: Result!
        group.enter()
        onResult { output in
            result = output
            group.leave()
        }
        group.wait()
        return result
    }
    
}

extension Promise {
    
    public class Setter {
        weak fileprivate var promise: Promise<T, E>?
        
        fileprivate init(promise: Promise<T, E>) {
            self.promise = promise
        }
    }
    
}

extension Promise.Setter {
    
    /// Call this when the promise is fulfilled
    public func success(with value: T) {
        promise?.success(with: value)
    }
    
    /// Call this when the promise has an error
    public func error(with value: E) {
        promise?.error(with: value)
    }
    
}

