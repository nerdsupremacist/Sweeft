//
//  Defaultable.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

/// A Type with a Default Value
public protocol Defaultable {
    
    /// Default Value for Type
    static var defaultValue: Self { get }
}

public extension Defaultable {
    
    /**
     Will generate an array populated with default values
     
     - Parameter size: size of the array. (Default: 0)
     */
    static func array(ofSize size: Int = 0) -> [Self] {
        if size > 0 {
            return (0..<size) => **{ defaultValue }
        } else {
            return []
        }
    }
    
}
