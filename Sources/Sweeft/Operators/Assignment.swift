//
//  Assignment.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

infix operator <-: AssignmentPrecedence

/**
 nil-proof Assignment. Will only assign the value if the value is not nil
 
 - Parameters:
 - variable: variable you want to assign it to
 - value: value you want to assign
 */
public func <-<V>(_ variable: inout V?, _ value: V?) {
    variable = value ?? variable
}

/**
 nil-proof Assignment. Will only assign the value if the value is not nil
 
 - Parameters:
 - variable: variable you want to assign it to
 - value: value you want to assign
 */
public func <-<V>(_ variable: inout V, _ value: V?) {
    variable = value ?? variable
}

/**
 Map assignment. Will assign the Result of map
 
 - Parameters:
 - items: array
 - handler: mapping function
 */
public func <-<T>(_ items: inout [T], _ handler: (T) -> (T)) {
    items = items => handler
}

/**
 Map assignment. Will assign the Result of map
 
 - Parameters:
 - items: array
 - handler: mapping function
 */
public func <-<T>(_ items: inout [T], _ handler: (T, Int) -> (T)) {
    items = items => handler
}

/**
 FlatMap assignment. Will assign the Result of flatMap
 
 - Parameters:
 - items: array
 - handler: flatMapping function
 */
public func <-<T>(_ items: inout [T], _ handler: (T) -> (T?)) {
    items = items ==> handler
}

infix operator <|: AssignmentPrecedence

/**
 Filter assignment. Will assign the Result of filter
 
 - Parameters:
 - items: array
 - handler: isIncluded function
 */
public func <|<T>(_ items: inout [T], _ handler: (T) -> Bool) {
    items = items |> handler
}

/**
 Filter assignment. Will assign the Result of filter
 
 - Parameters:
 - items: array
 - handler: isIncluded function
 */
public func <|<T>(_ items: inout [T], _ handler: (T, Int) -> Bool) {
    items = items |> handler
}

infix operator <=>: AssignmentPrecedence

/**
 Swap. Will swap the two elements
 
 - Parameters:
    - a: first Element
    - b: second Element
 */
public func <=><V>(_ a: inout V, _ b: inout V) {
    swap(&a, &b)
}

postfix operator .?

/**
 Unwrap with default. Will safely unwrap the value and return the default value of the type when nil
 
 - Parameters:
    - value: Value
 
 - Returns: Value when not nil and type default when nil
 */
public postfix func .?<V: Defaultable>(_ value: V?) -> V {
    return value ?? V.defaultValue
}

/**
 Unwrap array with default.
 
 - Parameters:
    - items: array
 
 - Returns: array with all the elements unwrapped with default.
 */
public postfix func .?<T: Defaultable, C: Collection where C.Iterator.Element == T?>(_ items: C) -> [T] {
    return items => (.?)
}

prefix operator ??

/**
 nil-Check
 
 - Parameters:
    - value: Value
 
 - Returns: Whether or not it's nil
 */
public prefix func ??<V>(_ value: V?) -> Bool {
    return value != nil
}
