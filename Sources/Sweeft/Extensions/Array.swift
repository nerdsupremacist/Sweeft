//
//  Arrays.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Array {
    
    // Array with Elements and indexes for better for loops.
    var indexes: [(Element, Int)] {
        if isEmpty {
            return []
        }
        return (0..<count).map { (self[$0], $0) }
    }
    
    /**
     Map with index
     
     - Parameters:
     - transform: tranform function with index
     
     - Returns: transformed array
     */
    func map<T>(_ transform: (Element, Int) -> T) -> [T] {
        return indexes => transform
    }
    
    /**
     For each with index
     
     - Parameters:
     - body: body function with index
     */
    func forEach(_ body: (Element, Int) -> Void) {
        indexes => body
    }
    
    /**
     Filter with index
     
     - Parameters:
     - isIncluded: isIncluded function with index
     
     - Returns: filtered array
     */
    func filter(_ isIncluded: (Element, Int) -> Bool) -> [Element] {
        return (indexes |> isIncluded).map { $0.0 }
    }
    
    /**
     Reduce with index
     
     - Parameters:
     - initialResult: Accumulator
     - nextPartialResult: resulthandler with index
     
     - Returns: Result
     */
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: @escaping (Result, Element, Int) -> Result) -> Result {
        return indexes.reduce(initialResult) { nextPartialResult($0, $1.0, $1.1) }
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
        return (0..<number).map { self[$0] }
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
    
    /**
     Will sum all of the Elements of the array toghether
     
     - Parameters:
     - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of sum
     */
    func sum(_ mapper: (Element) -> (Double)) -> Double {
        return self.map(mapper).reduce(0, +)
    }
    
    /**
     Will sum all of the Elements of the array toghether
     
     - Parameters:
     - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of sum
     */
    func sum(_ mapper: (Element) -> (Int)) -> Int {
        return Int(sum(mapper))
    }
    
    /**
     Will multiply all of the Elements of the array toghether
     
     - Parameters:
     - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of multiplication
     */
    func multiply(_ mapper: (Element) -> (Double)) -> Double {
        return self.map(mapper).reduce(1, *)
    }
    
    /**
     Will multiply all of the Elements of the array toghether
     
     - Parameters:
     - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of multiplication
     */
    func multiply(_ mapper: (Element) -> (Int)) -> Int {
        return Int(multiply(mapper))
    }
    
}

public extension Array {
    
    /// Default Value
    static var defaultValue: [Element] {
        return [Element]()
    }
    
}
