//
//  PromiseSetterProtocol.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/22/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Foundation

public protocol PromiseSetterProtocol {
    associatedtype ResultType
    associatedtype ErrorType: Error
    func onCancel(call handler: @escaping () -> ())
    func write(result: Result<ResultType, ErrorType>)
}

extension PromiseSetterProtocol {
    
    /// Call this when the promise is fulfilled
    public func success(with value: ResultType) {
        write(result: .value(value))
    }
    
    /// Call this when the promise has an error
    public func error(with error: ErrorType) {
        write(result: .error(error))
    }
    
}
