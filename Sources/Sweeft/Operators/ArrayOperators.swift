//
//  ArrayOperators.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

/**
 Concretalize. Will remove all the optionals from an array.
 
 - Parameters:
 - items: array
 
 - Returns: array without optionals
 */
public prefix func !<T>(_ items: [T?]) -> [T] {
    return items ==> { $0 }
}

/**
 Append.
 
 - Parameters:
 - a: array
 - b: array
 
 - Returns: array with all of the contents of both
 */
public func +<V>(_ a: [V], _ b: [V]) -> [V] {
    var a = a
    a.append(contentsOf: b)
    return a
}

/**
 Append.
 
 - Parameters:
 - a: array
 - b: value
 
 - Returns: array with extra value b
 */
public func +<V>(_ a: [V], _ b: V?) -> [V] {
    guard let b = b else {
        return a
    }
    return a + [b]
}

/**
 Append.
 
 - Parameters:
 - a: array
 - b: value
 
 - Returns: array with extra value b
 */
public func +<V>(_ a: [V]?, _ b: V?) -> [V] {
    return (a ?? []) + b
}

/**
 Append.
 
 - Parameters:
 - a: array
 - b: array
 
 - Returns: array with all of the contents of both
 */
public func +<V>(_ a: [V]?, _ b: [V]?) -> [V] {
    guard let a = a else {
        return b ?? []
    }
    guard let b = b else {
        return a
    }
    return a + b
}

infix operator +=: AssignmentPrecedence

/**
 nil-proof Append. Will only append the value if it's not nil
 If the array is nil it will be created.
 
 - Parameters:
 - array: variable you want to assign it to
 - value: value you want to assign
 */
public func +=<V>(_ array: inout [V]?, _ value: V?) {
    array = array + value
}

/**
 nil-proof Concat. Will only contatenate b if it's not nil
 If the array is nil it will be created.
 
 - Parameters:
 - array: variable you want to assign it to
 - value: value you want to assign
 */
public func +=<V>(_ a: inout [V]?, _ b: [V]?) {
    a = a + b
}
