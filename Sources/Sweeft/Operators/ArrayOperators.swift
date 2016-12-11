//
//  ArrayOperators.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation


/**
 Concretalize. Will remove all the optionals from an array.
 
    - Parameter items: array
 
 - Returns: array without optionals
 */
public prefix func !<T, C: Collection where C.Iterator.Element == T?>(_ items: C?) -> [T] {
    return items ==> id
}

/**
 Append.
 
 - Parameter a: array
 - Parameter b: array
 
 - Returns: array with all of the contents of both
 */
public func +<V>(_ a: [V], _ b: [V]) -> [V] {
    var a = a
    a.append(contentsOf: b)
    return a
}

/**
 Concatenate Dictionaries
 
 - Parameter a: dictionary
 - Parameter b: dictionary
 
 - Returns: dictionary containing the contents of the two.
 */
public func +<K, V>(_ a: [K:V], _ b: [K:V]) -> [K:V] {
    return b ==> a ** {
        var dict = $0
        dict[$1.key] = $1.value
        return dict
    }
}

/**
 Concatenate Dictionaries
 
 - Parameter a: dictionary
 - Parameter b: dictionary
 
 - Returns: dictionary containing the contents of the two.
 */
public func +<K, V>(_ a: [K:V], _ b: [K:V?]) -> [K:V] {
    return b ==> a ** {
        var dict = $0
        if let value = $1.value {
            dict[$1.key] = value
        }
        return dict
    }
}

/**
 Append.
 
 - Parameter a: array
 - Parameter b: value
 
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
 
 - Parameter a: array
 - Parameter b: value
 
 - Returns: array with extra value b
 */
public func +<V>(_ a: [V]?, _ b: V?) -> [V] {
    return (a ?? []) + b
}

/**
 Append.
 
 - Parameter a: array
 - Parameter b: array
 
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

/**
 Concatenate Dictionaries
 
 - Parameter a: dictionary
 - Parameter b: dictionary
 
 - Returns: dictionary containing the contents of the two.
 */
public func +<K, V>(_ a: [K:V]?, _ b: [K:V]?) -> [K:V]? {
    guard let a = a else {
        return [:]
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
 
 - Parameter array: variable you want to assign it to
 - Parameter value: value you want to assign
 */
public func +=<V>(_ array: inout [V]?, _ value: V?) {
    array = array + value
}

/**
 nil-proof Concat. Will only contatenate b if it's not nil
 If the array is nil it will be created.
 
 - Parameter array: variable you want to assign it to
 - Parameter value: value you want to assign
 */
public func +=<V>(_ a: inout [V]?, _ b: [V]?) {
    a = a + b
}

/**
 Safe Array index Access
 
 - Parameter array: array you want to access
 - Parameter index: index you want to access
 
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
 
 - Parameter array: array you want to access
 - Parameter index: index you want to access
 
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
 
 - Parameter dictionary: dictionary you want to access
 - Parameter key: key of the dictionary you want to access
 
 - Returns: Value at key
 */
public func |<K, V>(_ dictionary: [K:V], _ key: K) -> V? {
    return dictionary[key]
}

/**
 Safe Dictionary value Access
 
 - Parameter dictionary: dictionary you want to access
 - Parameter key: key of the dictionary you want to access
 
 - Returns: Value at key
 */
public func |<K, V>(_ dictionary: [K:V]?, _ key: K) -> V? {
    return (dictionary.?)[key]
}

/**
 Is subset
 
 - Parameter a: Set
 - Parameter b: Set
 
 - Returns: is a a subset of b
 */
public func <=<T: Hashable>(_ a: Set<T>, _ b: Set<T>) -> Bool {
    return a.isSubset(of: b)
}

/**
 Is superset
 
 - Parameters:
    - a: Set
    - b: Set
 - Returns: is a a superset of b
 */
public func >=<T: Hashable>(_ a: Set<T>, _ b: Set<T>) -> Bool {
    return b <= a
}

/**
 Is strict subset
 
 - Parameter a: Set
 - Parameter b: Set
 
 - Returns: is a a strict subset of b
 */
public func <<T: Hashable>(_ a: Set<T>, _ b: Set<T>) -> Bool {
    return a <= b && a.count < b.count
}

/**
 Is strict superset
 
 - Parameter a: Set
 - Parameter b: Set
 
 - Returns: is a a strict superset of b
 */
public func ><T: Hashable>(_ a: Set<T>, _ b: Set<T>) -> Bool {
    return b < a
}

infix operator <>: ComparisonPrecedence

/**
 Is disjoint
 
 - Parameter a: Set
 - Parameter b: Set
 
 - Returns: are a and b disjoint
 */
public func <><T: Hashable>(_ a: Set<T>, _ b: Set<T>) -> Bool {
    return a.isDisjoint(with: b)
}

prefix operator <>

/**
 Reverse Collection
 
 - Parameter items: Collection
 
 - Returns: Array containing the elements of C in reversed order
 */
public prefix func <><C: Collection>(_ items: C) -> [C.Iterator.Element] {
    return items.reversed()
}
