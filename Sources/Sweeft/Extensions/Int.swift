//
//  Int.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Int {
    
    var primeFactors: [Int] {
        if self == 0 {
            return [self]
        }
        if self < 0 {
            return [-1] + (-self).primeFactors
        }
        let bound = Int(sqrt(Double(self))) + 1
        guard let firstPrime = (2...bound).filter({ self % $0 == 0 }).first else {
            return [self]
        }
        return [firstPrime] + (self / firstPrime).primeFactors
    }
    
    /// Will say it is prime
    var isPrime: Bool {
        if self < 2 {
            return false
        }
        let bound = Int(sqrt(Double(self))) + 1
        return (2...bound)
            .filter { self % $0 == 0 }
            .isEmpty
    }
    
    /// Will say if the string representation is a palindrome. (Without signing)
    var isPalindrome: Bool {
        return abs(self).description.isPalindrome
    }
    
    /// Will return a reversed version of the integer
    var reversed: Int {
        return self | { $0.description.reversed } | Int.init.?
    }
    
}

extension Int: Defaultable {
    
    /// Default Value
    public static let defaultValue = 0
    
}
