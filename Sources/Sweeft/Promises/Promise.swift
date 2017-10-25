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
    case cancelled
    
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
    func onResult(call handler: @escaping (Result<ResultType, ErrorType>) -> ()) -> Promise<ResultType, ErrorType>
}

/// Promise Structs to prevent you from nesting callbacks over and over again
public class Promise<T, E: Error>: PromiseBody {
    /// Type of the success
    typealias SuccessHandler = (T) -> ()
    /// Type of the success
    typealias ErrorHandler = (E) -> ()
    /// For handling your promise being cancelled
    typealias CancelHandler = () -> ()
    // Result Type
    public typealias Result = Sweeft.Result<T, E>
    // Type of result handler
    public typealias ResultHandler = (Result) -> ()
    
    /// All the handlers
    var successHandlers = [SuccessHandler]()
    var errorHandlers = [ErrorHandler]()
    var resultHandlers = [ResultHandler]()
    
    private var cancelHandlers = [CancelHandler]()
    
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
    
    public static func new(completionQueue: DispatchQueue = .global(),
                           _ handle: (Promise<T, E>.Setter) -> ()) -> Promise<T, E> {
        
        return Promise<T, E>(completionQueue: completionQueue, handle)
    }
    
    fileprivate func onCancel(call handler: @escaping CancelHandler) {
        if case .cancelled = state {
            return handler()
        }
        cancelHandlers.append(handler)
    }
    
    public func cancel() {
        guard case .waiting = state else { return }
        state = .cancelled
        print(cancelHandlers.count)
        cancelHandlers => { $0() }
        successHandlers = []
        errorHandlers = []
        resultHandlers = []
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
    
    fileprivate func write(result: Result) {
        
        guard !state.isDone else { return }
        state = .done(result: result)
        
        switch result {
        case .value(let value):
            let handlers = successHandlers + (resultHandlers => calling)
            completionQueue >>> {
                handlers => { $0(value) }
            }
        case .error(let error):
            let handlers = errorHandlers + (resultHandlers => calling)
            completionQueue >>> {
                handlers => { $0(error) }
            }
        }
        successHandlers = []
        errorHandlers = []
        resultHandlers = []
    }
    
    func apply<A, B>(to setter: Promise<A, B>.Setter, transform: @escaping (Result) -> Promise<A, B>.Result) {
        onResult(call: transform >>> setter.write)
        setter.onCancel { [weak self] in self?.cancel() }
    }
    
    public func map<A, B>(completionQueue: DispatchQueue = .global(),
                          _ transform: @escaping (Result) -> Promise<A, B>.Result) -> Promise<A, B> {
        
        return .new(completionQueue: completionQueue) { setter in
            self.apply(to: setter, transform: transform)
        }
    }
    
    /// Will create a Promise that is based on this promise but maps the result
    public func map<V>(completionQueue: DispatchQueue = .global(),
                       _ transform: @escaping (T) -> V) -> Promise<V, E> {
        
        return map(completionQueue: completionQueue) { $0.map(transform) }
    }
    
    public func flatMap<V>(completionQueue: DispatchQueue = .global(),
                           _ mapper: @escaping (T) -> Promise<V, E>) -> Promise<V, E> {
        
        return .new(completionQueue: completionQueue) { setter in
            setter.onCancel { [weak self] in self?.cancel() }
            map(mapper).onResult { result in
                switch result {
                case .value(let resultPromise):
                    resultPromise.apply(to: setter, transform: id)
                case .error(let error):
                    setter.error(with: error)
                }
            }
        }
    }
    
    public func generalizeError(completionQueue: DispatchQueue = .global()) -> Promise<T, AnyError> {
        return map(completionQueue: completionQueue) { $0.map(AnyError.error) }
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
        fileprivate let promise: Promise<T, E>
        
        fileprivate init(promise: Promise<T, E>) {
            self.promise = promise
        }
    }
    
}

extension Promise.Setter {
    
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
    
    /// Call this when the promise is fulfilled
    public func success(with value: T) {
        write(result: .value(value))
    }
    
    /// Call this when the promise has an error
    public func error(with error: E) {
        write(result: .error(error))
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

extension Promise.Setter.Weak {
    
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

