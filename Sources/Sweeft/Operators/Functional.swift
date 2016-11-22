//
//  Functional.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

/// Pipe. Will pass the value to a function. Like in Bash
public func |<T, V>(_ value: T?, function: ((T) -> V)?) -> V? {
    guard let value = value else {
        return nil
    }
    return function?(value)
}

/// Pipe. Will pass the value to a function. Like in Bash
public func |<T, V>(_ value: T?, function: ((T) -> V)) -> V? {
    guard let value = value else {
        return nil
    }
    return function(value)
}

/// Will return a function that returns if the result of the original function was not nil
public prefix func .?<T,V>(_ handler: @escaping ((T) -> V?)) -> (T) -> Bool {
    return { .?($0 | handler) }
}

infix operator =>

/// Map array using handler.
public func =><T, V>(_ items: [T], _ handler: (T) -> (V)) -> [V] {
    return items.map(handler)
}

/// Call handler for each item in array.
public func =><T>(_ items: [T], _ handler: (T) -> ()) {
    items.forEach(handler)
}

infix operator ==>

/// FlatMap array using handler
public func ==><T, V>(_ items: [T], _ handler: (T) -> (V?)) -> [V] {
    return items.flatMap(handler)
}

infix operator |>

/// Filter array using handler
public func |><V>(_ items: [V], _ handler: (V) -> Bool) -> [V] {
    return items.filter(handler)
}

/// Filter array using handler
public func |><V>(_ items: [V], _ handler: @escaping (V) -> Bool?) -> [V] {
    return items |> { handler($0).? }
}

prefix operator **

/// Will ignore the input to a function
public prefix func **<T, V>(_ handler: @escaping () -> (V)) -> (T) -> (V) {
    return { _ in
        return handler()
    }
}

postfix operator **

/// Will ignore the output of a function
public postfix func **<T, V>(_ handler: @escaping (T) -> (V)) -> (T) -> () {
    return { input in
        _ = handler(input)
    }
}

/// Will turn any function into a function that accepts it's parameters as optionals
public prefix func !<T, V>(_ handler: @escaping (T) -> (V)) -> (T?) -> (V?) {
    return { $0 | handler }
}
