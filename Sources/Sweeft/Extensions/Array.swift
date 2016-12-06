//
//  Arrays.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Array with Elements and indexes for better for loops.
    var withIndex: [(Element, Int)] {
        if isEmpty {
            return []
        }
        return (0..<count) => { (self[$0], $0) }
    }
    
    /**
     Map with index
     
     - Parameters:
        - transform: tranform function with index
     
     - Returns: transformed array
     */
    func map<T>(_ transform: (Element, Int) -> T) -> [T] {
        return withIndex => transform
    }
    
    /**
     For each with index
     
     - Parameters:
        - body: body function with index
     */
    func forEach(_ body: (Element, Int) -> Void) {
        withIndex => body
    }
    
    /**
     Filter with index
     
     - Parameters:
        - isIncluded: isIncluded function with index
     
     - Returns: filtered array
     */
    func filter(_ isIncluded: (Element, Int) -> Bool) -> [Element] {
        return (withIndex |> isIncluded).map { $0.0 }
    }
    
    /**
     Reduce with index
     
     - Parameters:
        - initialResult: Accumulator
        - nextPartialResult: resulthandler with index
     
     - Returns: Result
     */
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: @escaping (Result, Element, Int) -> Result) -> Result {
        return withIndex.reduce(initialResult) { nextPartialResult($0, $1.0, $1.1) }
    }
    
    /**
     Reduce with first item as partial result
     - Parameters:
        - nextPartialResult: resulthandler
     
     - Returns: Result
     */
    func reduce(_ nextPartialResult: @escaping (Element, Element) -> Element) -> Element? {
        guard let first = first else {
            return nil
        }
        return array(withLast: count - 1).reduce(first, nextPartialResult)
    }
    
    /**
     Reduce with first item as partial result and with index
     - Parameters:
        - nextPartialResult: resulthandler with index
     
     - Returns: Result
     */
    func reduce(_ nextPartialResult: @escaping (Element, Element, Int) -> Element) -> Element? {
        guard let first = first else {
            return nil
        }
        return array(withLast: count - 1).reduce(first, nextPartialResult)
    }
    
    /**
     Will turn any Array into a Dictionary with a handler
     
     - Parameters:
        - byDividingWith: Mapping function that breaks every element into a key and a value with index
     
     - Returns: Resulting dictionary
     */
    func dictionary<K, V>(byDividingWith handler: @escaping (Element, Int) -> (K, V)) -> [K:V] {
        return reduce([:]) { dict, item, index in
            var dict = dict
            let (key, value) = handler(item, index)
            dict[key] = value
            return dict
        }
    }
    
    /**
     Will give you the first n Elements of an Array
     
     - Parameters:
        - withFirst number: Number of items you want
     
     - Returns: Array with the first n Elements
     */
    func array(withFirst number: Int) -> [Element] {
        if number > count {
            return self
        }
        if number < 1 {
            return []
        }
        return (0..<number) => { self[$0] }
    }
    
    /**
     Will give you the last n Elements of an Array
     
     - Parameters:
        - withFirst number: Number of items you want
     
     - Returns: Array with the last n Elements
     */
    func array(withLast number: Int) -> [Element] {
        return self.reversed().array(withFirst: number).reversed()
    }
    
}

extension Array where Element: Hashable {
    
    var noDuplicates: [Element] {
        return set.array
    }
    
}

extension Array: Defaultable {
    
    /// Default Value
    public static var defaultValue: [Element] {
        return []
    }
    
}
