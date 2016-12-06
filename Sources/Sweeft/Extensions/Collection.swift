//
//  Collection.swift
//  Pods
//
//  Created by Mathias Quintero on 12/5/16.
//
//

import Foundation

public extension Collection where Iterator.Element: Hashable {
    
    /// Will turn any Collection into a Set
    var set: Set<Iterator.Element> {
        return Set(array)
    }
    
}

public extension Collection {
    
    /// Will Turn any Collection into an Array for easier handling
    var array: [Iterator.Element] {
        return self => { $0 }
    }
    
    /**
     Will turn any Collection into a Dictionary with a handler
     
     - Parameters:
        - byDividingWith: Mapping function that breaks every element into a key and a value
     
     - Returns: Resulting dictionary
     */
    func dictionary<K, V>(byDividingWith handler: (Iterator.Element) -> (K, V)) -> [K:V] {
        return reduce([:]) { dict, item in
            var dict = dict
            let (key, value) = handler(item)
            dict[key] = value
            return dict
        }
    }
    
    /**
     Will sum all of the Elements
     
     - Parameters:
        - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of sum
     */
    func sum(_ mapper: (Iterator.Element) -> (Double)) -> Double {
        return self.map(mapper).reduce(0, +)
    }
    
    /**
     Will sum all of the Elements
     
     - Parameters:
        - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of sum
     */
    func sum(_ mapper: (Iterator.Element) -> (Int)) -> Int {
        return Int(sum(mapper))
    }
    
    /**
     Will multiply all of the Elements
     
     - Parameters:
        - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of multiplication
     */
    func multiply(_ mapper: (Iterator.Element) -> (Double)) -> Double {
        return self.map(mapper).reduce(1, *)
    }
    
    /**
     Will multiply all of the Elements
     
     - Parameters:
        - mapper: Mapping function that returns the value for an Element
     
     - Returns: Result of multiplication
     */
    func multiply(_ mapper: (Iterator.Element) -> (Int)) -> Int {
        return Int(multiply(mapper))
    }
    
}
