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
public prefix func !<T, C: Collection where C.Iterator.Element == T?>(_ items: C) -> [T] {
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

/**
 Safe Array index Access
 
 - Parameters:
    - array: array you want to access
    - index: index you want to access
 - Returns: Value at index
 */
public func |<T>(_ items: [T], _ index: Int) -> T? {
    if index < 0, abs(index) < items.count {
        return items | (items.count + index)
    }
    if index < items.count, index >= 0 {
        return items[index]
    }
    return nil
}

/**
 Safe Array index Access
 
 - Parameters:
    - array: array you want to access
    - index: index you want to access
 - Returns: Value at index
 */
public func |<T>(_ items: [T]?, _ index: Int) -> T? {
    guard let items = items else {
        return nil
    }
    return items | index
}

/**
 Safe Dictionary value Access
 
 - Parameters:
    - dictionary: dictionary you want to access
    - key: key of the dictionary you want to access
 - Returns: Value at key
 */
public func |<K, V>(_ dictionary: [K:V], _ key: K) -> V? {
    return dictionary[key]
}

/**
 Safe Dictionary value Access
 
 - Parameters:
    - dictionary: dictionary you want to access
    - key: key of the dictionary you want to access
 - Returns: Value at key
 */
public func |<K, V>(_ dictionary: [K:V]?, _ key: K) -> V? {
    return (dictionary.?)[key]
}
