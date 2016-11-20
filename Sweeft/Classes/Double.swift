//
//  Double.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

extension Double {
    
    var isPalindrome: Bool {
        return description.replacingOccurrences(of: ".", with: "").isPalindrome
    }
    
}

extension Double: Defaultable {
    
    static let defaultValue = 0.0
    
}
