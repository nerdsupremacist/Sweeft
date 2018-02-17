//
//  Dispatcher.swift
//  Sweeft
//
//  Created by Mathias Quintero on 2/5/18.
//  Copyright © 2018 Mathias Quintero. All rights reserved.
//

import Foundation

public protocol Dispatcher {
    func perform(operation: @escaping () -> ())
    func perform<P: PromiseProtocol>(promise: @escaping () -> P) -> Promise<P.ResultType, P.ErrorType>
}

extension Dispatcher {
    
    public func perform<P: PromiseProtocol>(promise: @escaping () -> P) -> Promise<P.ResultType, P.ErrorType> {
        return .new(dispatcher: self) { setter in
            let promise = promise()
            promise.onResult(in: nil, call: setter.write)
            setter.onCancel { [weak promise] in promise?.cancel() }
        }
    }
    
}

extension DispatchQueue: Dispatcher {
    
    public func perform(operation: @escaping () -> ()) {
        self.async(execute: operation)
    }
    
}

public struct ImmediateDispatcher: Dispatcher {
    
    public static let `default` = ImmediateDispatcher()
    
    public func perform(operation: @escaping () -> ()) {
        operation()
    }
    
}
