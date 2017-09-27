//
//  PromiseHandler.swift
//  Pods
//
//  Created by Mathias Quintero on 12/11/16.
//
//

import Foundation

/// Enum For Representing an Empty Error Domain
public enum NoError: Error {}
public enum AnyError: Error {
    case error(Error)
}

extension AnyError: GenerizableError {
    
    public init(error: Error) {
        self = .error(error)
    }
    
}

extension AnyError {
    
    public var error: Error {
        switch self {
        case .error(let error):
            return error
        }
    }
    
}
