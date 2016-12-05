//
//  Dictionary.swift
//  Pods
//
//  Created by Mathias Quintero on 12/5/16.
//
//

import Foundation

public extension Dictionary where Value: Hashable {
    
    // Returns a flipped mapping of the Dictionary.
    var flipped: [Value:Key] {
        return dictionary { ($1, $0) }
    }
    
}

extension Dictionary: Defaultable {
    
    /// Default Value
    public static var defaultValue: [Key:Value] {
        return [:]
    }
    
}
