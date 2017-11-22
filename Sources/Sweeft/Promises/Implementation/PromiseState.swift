//
//  PromiseState.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/22/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Foundation

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
