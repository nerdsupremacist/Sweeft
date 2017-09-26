//
//  Result.swift
//  Sweeft
//
//  Created by Mathias Quintero on 8/20/17.
//

import Foundation

func calling<R, E, V>(_ handler: @escaping (Result<R, E>) -> (V)) -> (R) -> (V) {
    return { handler(.value($0)) }
}

func calling<R, E, V>(_ handler: @escaping (Result<R, E>) -> (V)) -> (E) -> (V) {
    return { handler(.error($0)) }
}

public enum Result<T, E: Error> {
    case value(T)
    case error(E)
}

extension Result {
    
    public var value: T? {
        guard case .value(let value) = self else {
            return nil
        }
        return value
    }
    
    public var error: E? {
        guard case .error(let error) = self else {
            return nil
        }
        return error
    }
    
}

extension Result {
    
    public func run() throws -> T {
        switch self {
        case .value(let value):
            return value
        case .error(let error):
            throw error
        }
    }
    
}

extension Result {
    
    public func map<V>(_ transform: (T) throws -> V) rethrows -> Result<V, E> {
        
        switch self {
        case .value(let value):
            return .value(try transform(value))
            
        case .error(let error):
            return .error(error)
        }
        
    }
    
    public func flatMap<V>(_ transform: (T) throws -> Result<V, E>) rethrows -> Result<V, E> {
        
        switch try self.map(transform) {
        case .value(let result):
            return result
        case .error(let error):
            return .error(error)
        }
    }
    
}
