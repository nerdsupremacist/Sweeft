//
//  PromiseProtocol.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/22/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Foundation


public protocol PromiseProtocol: AnyObject {
    associatedtype ResultType
    associatedtype ErrorType
    associatedtype Setter: PromiseSetterProtocol where ResultType == Setter.ResultType, ErrorType == Setter.ErrorType
    
    @discardableResult func onSuccess(in queue: DispatchQueue?,
                                      call handler: @escaping (ResultType) -> ()) -> Self
    
    @discardableResult func onError(in queue: DispatchQueue?,
                                    call handler: @escaping (ErrorType) -> ()) -> Self
    
    @discardableResult func onResult(in queue: DispatchQueue?,
                                     call handler: @escaping (Result<ResultType, ErrorType>) -> ()) -> Self
    
    func cancel()
}

extension PromiseProtocol {
    
    func apply<S>(to setter: S,
                  transform: @escaping (Result<ResultType, ErrorType>) -> Result<S.ResultType, S.ErrorType>) where S: PromiseSetterProtocol {
        
        onResult(in: nil) { setter.write(result: transform($0)) }
        setter.onCancel { [weak self] in self?.cancel() }
    }
    
}

extension PromiseProtocol {
    
    public func mapResult<A, B>(completionQueue: DispatchQueue = .global(),
                                _ transform: @escaping (Result<ResultType, ErrorType>) -> Result<A, B>) -> Promise<A, B> {
        
        return .new(completionQueue: completionQueue) { setter in
            self.apply(to: setter, transform: transform)
        }
    }
    
    /// Will create a Promise that is based on this promise but maps the result
    public func map<V>(completionQueue: DispatchQueue = .global(),
                       _ transform: @escaping (ResultType) -> V) -> Promise<V, ErrorType> {
        
        return mapResult(completionQueue: completionQueue) { $0.map(transform) }
    }
    
    public func flatMap<V>(completionQueue: DispatchQueue = .global(),
                           _ mapper: @escaping (ResultType) -> Promise<V, ErrorType>) -> Promise<V, ErrorType> {
        
        return .new(completionQueue: completionQueue) { setter in
            setter.onCancel { [weak self] in self?.cancel() }
            self.map(mapper).onResult { result in
                switch result {
                case .value(let resultPromise):
                    resultPromise.apply(to: setter, transform: id)
                case .error(let error):
                    setter.error(with: error)
                }
            }
        }
    }
    
    public func generalizeError(completionQueue: DispatchQueue = .global()) -> Promise<ResultType, AnyError> {
        return mapResult(completionQueue: completionQueue) { $0.map(AnyError.error) }
    }
    
    public func wait() -> Result<ResultType, ErrorType> {
        let group = DispatchGroup()
        var result: Result<ResultType, ErrorType>!
        group.enter()
        onResult(in: nil) { output in
            result = output
            group.leave()
        }
        group.wait()
        return result
    }
    
}

extension PromiseProtocol where ErrorType: GenerizableError {
    
    public func mapAndCatch<V>(completionQueue: DispatchQueue = .global(),
                               _ mapper: @escaping (ResultType) throws -> V) -> Promise<V, ErrorType> {
        
        return mapResult(completionQueue: completionQueue) { result in
            return result.mapAndCatch(mapper)
        }
    }
    
}
