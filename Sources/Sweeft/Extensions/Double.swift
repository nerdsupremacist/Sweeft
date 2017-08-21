//
//  Double.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Double {
    
    /// Will say if the string representation is a palindrome. (Without signing or dots.)
    var isPalindrome: Bool {
        let abs = Swift.abs(self)
        return abs.description.replacingOccurrences(of: ".", with: "").isPalindrome
    }
    
}

extension Double: Defaultable {
    
    /// Default Value
    public static let defaultValue = 0.0
    
}

extension Double: Serializable {
    
    /// JSON Value
    public var json: JSON {
        return .double(self)
    }
    
}
