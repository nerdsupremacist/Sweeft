//
//  ObjectStatus.swift
//  Pods
//
//  Created by Mathias Quintero on 12/11/16.
//
//

import Foundation

public protocol ObjectStatus {
    associatedtype Value: StatusSerializable
    associatedtype Key: StatusKey
    
    static var key: Key { get }
    static var defaultValue: Value { get }
}

public extension ObjectStatus {
    
    static var value: Value {
        get {
            return Value.init(from: DictionaryStatus(key: key).value) ?? defaultValue
        }
        set {
            var status = DictionaryStatus(key: key)
            status.value = newValue.serialized
        }
    }
    
    static func reset() {
        value = defaultValue
    }
    
}
