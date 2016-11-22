//
//  Functional.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

//: Pipe. Will pass the value to a function
public func |<T, V>(_ value: T?, function: ((T) -> V)?) -> V? {
    guard let value = value else {
        return nil
    }
    return function?(value)
}

public func |<T, V>(_ value: T?, function: ((T) -> V)) -> V? {
    guard let value = value else {
        return nil
    }
    return function(value)
}

//: Will return a function that returns if the result of the original function was not nil
public prefix func .?<T,V>(_ handler: @escaping ((T) -> V?)) -> (T) -> Bool {
    return { .?($0 | handler) }
}

//: Implicit Map Operator
infix operator =>

public func =><T, V>(_ items: [T], _ handler: (T) -> (V)) -> [V] {
    return items.map(handler)
}

public func =><T>(_ items: [T], _ handler: (T) -> ()) {
    items.forEach(handler)
}

//: Implicit Flat Map Operator
infix operator ==>

public func ==><T, V>(_ items: [T], _ handler: (T) -> (V?)) -> [V] {
    return items.flatMap(handler)
}

//: Implicit filter operator
infix operator |>

public func |><V>(_ items: [V], _ handler: (V) -> Bool) -> [V] {
    return items.filter(handler)
}

public func |><V>(_ items: [V], _ handler: @escaping (V) -> Bool?) -> [V] {
    return items |> { handler($0).? }
}



//: Will ignore the input to a function
prefix operator **

public prefix func **<T, V>(_ handler: @escaping () -> (V)) -> (T) -> (V) {
    return { _ in
        return handler()
    }
}

//: Will ignore the output of a function
postfix operator **

public postfix func **<T, V>(_ handler: @escaping (T) -> (V)) -> (T) -> () {
    return { input in
        _ = handler(input)
    }
}

//: Will turn any function into a function that accepts it's parameters as optionals
public prefix func !<T, V>(_ handler: @escaping (T) -> (V)) -> (T?) -> (V?) {
    return { $0 | handler }
}
