//
//  Double.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Double {
    
    /// Will say if the string representation is a palindrome. (Without signing or dots.)
    var isPalindrome: Bool {
        return abs(self).description.replacingOccurrences(of: ".", with: "").isPalindrome
    }
    
}

extension Double: Defaultable {
    
    public static let defaultValue = 0.0
    
}
