//
//  Assignment.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

infix operator <-

/// Will assign the value to the variable if not nil
public func <-<V>(_ variable: inout V?, _ value: V?) {
    variable = value ?? variable
}

/// Will assign the value to the variable if not nil
public func <-<V>(_ variable: inout V, _ value: V?) {
    variable = value ?? variable
}

/// Will Assign the map Result
public func <-<T>(_ items: inout [T], _ handler: (T) -> (T)) {
    items = items => handler
}

/// Will Assign the flatMapResult
public func <-<T>(_ items: inout [T], _ handler: (T) -> (T?)) {
    items = items ==> handler
}

/// Will assign the filtered result
infix operator <|

public func <|<T>(_ items: inout [T], _ handler: (T) -> Bool) {
    items = items |> handler
}

/// Will remove all the optional values from an array
public prefix func !<T>(_ items: [T?]) -> [T] {
    return items ==> { $0 }
}

infix operator <=>

/// Will swap the two variables
public func <=><V>(_ a: inout V, _ b: inout V) {
    swap(&a, &b)
}

postfix operator .?

/// Will safely unwrapp any defaultable value
public postfix func .?<V: Defaultable>(_ value: V?) -> V {
    return value ?? V.defaultValue
}

/// Will safely unwrapp all the items in the array.
public postfix func .?<V: Defaultable>(_ items: [V?]) -> [V] {
    return items => (.?)
}

prefix operator .?

/// Will confirm if value is not nil
public prefix func .?<V>(_ value: V?) -> Bool {
    return value != nil
}
