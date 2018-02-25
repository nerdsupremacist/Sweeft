//
//  Promise.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

public typealias ResultPromise<R> = Promise<R, AnyError>

/// Promise Structs to prevent you from nesting callbacks over and over again
open class Promise<T, E: Error> {
    
    /// For handling your promise being cancelled
    typealias CancelHandler = () -> ()
    
    /// All the handlers
    final var resultHandlers = [Handler]()
    final var cancelHandlers = [CancelHandler]()
    
    final var state: PromiseState<T, E> = .waiting
    
    final let completionQueue: DispatchQueue
    final let internalQueue = DispatchQueue(label: "io.quintero.Sweeft.Promise")
    
    struct Handler {
        let handler: ResultHandler
        let completionQueue: DispatchQueue
        
        func call(with result: Result) {
            completionQueue >>> handler ** result
        }
    }
    
    /// Initializer
    public init(completionQueue: DispatchQueue = .global(),
                dispatcher: Dispatcher = ImmediateDispatcher.default,
                _ handle: @escaping (Setter) -> ()) {
        
        self.completionQueue = completionQueue
        dispatcher.perform {
            handle(.init(promise: self))
        }
    }
    
    public init(result: Result,
                completionQueue: DispatchQueue = .global()) {
        
        self.completionQueue = completionQueue
        self.state = .done(result: result)
    }
    
}

extension Promise {
    
    public static func new(completionQueue: DispatchQueue = .global(),
                           dispatcher: Dispatcher = ImmediateDispatcher.default,
                           _ handle: @escaping (Setter) -> ()) -> Promise<T, E> {
        
        return .init(completionQueue: completionQueue, dispatcher: dispatcher, handle)
    }
    
}

extension Promise {
    
    func onCancel(call handler: @escaping CancelHandler) {
        internalQueue.async(flags: .barrier) {
            if case .cancelled = self.state {
                handler()
            } else if case .waiting = self.state {
                self.cancelHandlers.append(handler)
            }
        }
    }
    
    func write(result: Result) {
        internalQueue.async(flags: .barrier) {
            
            guard !self.state.isDone else { return }
            self.state = .done(result: result)
            
            let handlers = self.resultHandlers
            
            self.resultHandlers = []
            self.cancelHandlers = []
            
            handlers => Handler.call ** result
            
        }
    }
    
}

extension Promise {
    
    public static func with(result: Result) -> Promise<T, E> {
        return Promise(result: result)
    }
    
    public static func successful(with value: T) -> Promise<T, E> {
        return .with(result: .value(value))
    }
    
    public static func errored(with value: E) -> Promise<T, E> {
        return .with(result: .error(value))
    }
    
}
