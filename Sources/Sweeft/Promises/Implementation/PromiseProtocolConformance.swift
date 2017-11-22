//
//  PromiseProtocolConformance.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/22/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Foundation

extension Promise: PromiseProtocol {
    
    public typealias ResultType = T
    public typealias ErrorType = E
    
    // ResultType
    public typealias Result = Sweeft.Result<ResultType, ErrorType>
    // Type of result handler
    public typealias ResultHandler = (Result) -> ()
    
    public final func cancel() {
        internalQueue.async(flags: .barrier) {
            guard case .waiting = self.state else { return }
            self.state = .cancelled
            self.resultHandlers = []
            self.cancelHandlers => { $0() }
        }
    }
    
    /**
     Add success handler
     
     - Parameter handler: function that should be called
     
     - Returns: PromiseHandler Object
     */
    @discardableResult public final func onSuccess(in queue: DispatchQueue? = nil,
                                                   call handler: @escaping (T) -> ()) -> Self {
        
        return onResult(in: queue) { $0.value | handler }
    }
    
    /// Add an error Handler
    @discardableResult public final func onError(in queue: DispatchQueue? = nil,
                                                 call handler: @escaping (E) -> ()) -> Self {
        
        return onResult(in: queue) { $0.error | handler }
    }
    
    /// Add a
    @discardableResult public func onResult(in queue: DispatchQueue? = nil,
                                            call handler: @escaping ResultHandler) -> Self {
        
        internalQueue.async(flags: .barrier) {
            
            let handler = Handler(handler: handler,
                                  completionQueue: queue ?? self.completionQueue)
            
            if let result = self.state.result {
                handler.call(with: result)
            } else if case .waiting = self.state {
                self.resultHandlers.append(handler)
            }
            
        }
        return self
    }
    
}
