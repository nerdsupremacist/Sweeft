//
//  SimpleStatus.swift
//  Pods
//
//  Created by Mathias Quintero on 12/11/16.
//
//

import Foundation

public protocol Status {
    associatedtype Value
    associatedtype Key: StatusKey
    
    static var key: Key { get }
    static var defaultValue: Value { get }
}

public extension Status {
    
    static var value: Value {
        get {
            return SimpleStatus(key: key, defaultValue: defaultValue).value
        }
        set {
            var status = SimpleStatus(key: key, defaultValue: defaultValue)
            status.value = newValue
        }
    }
    
    static func reset() {
        value = defaultValue
    }
    
}
