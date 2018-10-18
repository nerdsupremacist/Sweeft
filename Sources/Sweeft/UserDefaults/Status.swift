//
//  DefaultSaving.swift
//  Pods
//
//  Created by Mathias Quintero on 12/11/16.
//
//

import Foundation

public protocol Status {
    associatedtype Key: StatusKey
    associatedtype Value: Codable
    
    var storage: Storage { get }
    var key: Key { get }
    var defaultValue: Value { get }
}

extension Status {
    
    public var storage: Storage {
        return .userDefaults
    }
    
    public var value: Value {
        get {
            return try! storage.object.object(forKey: key.userDefaultsKey) ?? defaultValue
        }
        set {
            try! storage.object.set(newValue, forKey: key.userDefaultsKey)
        }
    }
    
}

struct SimpleStatus<K: StatusKey, V: Codable>: Status {
    let storage: Storage
    let key: K
    let defaultValue: V
}
