//
//  Int.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

extension Int {
    
    var isPrime: Bool {
        let bound = Int(sqrt(Double(self))) + 1
        return (2...bound)
            .filter { self % $0 == 0 }
            .isEmpty
    }
    
    var isPalindrome: Bool {
        return description.isPalindrome
    }
    
}

extension Int: Defaultable {
    
    static let defaultValue = 0
    
}
