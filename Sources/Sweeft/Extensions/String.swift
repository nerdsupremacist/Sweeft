//
//  Swift.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension String {
    
    /// Will say if the String is a palindrome
    var isPalindrome: Bool {
        return self.reversed == self
    }
    
    /// Will return the string reversed
    var reversed: String {
        return String(characters.reversed())
    }
    
    /**
     Will try to decipher the Date coded into a string
     
     - Parameters:
     - with format: format in which the date is coded (Optional: default is "dd:MM:yyyy hh:mm")
     
     - Returns: Date object for the time
     */
    func date(using format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
}

public extension String {
    
    /**
     Will say if a String matches a RegEx
     
     - Parameters:
     - pattern: RegEx you want to match
     - options: Extra options (Optional: Default is [])
     
     - Returns: Whether or not the string matches
     */
    func matches(pattern: String, options: NSRegularExpression.Options = []) throws -> Bool {
        let regex = try NSRegularExpression(pattern: pattern, options: options)
        return regex.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: 0.distance(to: utf16.count))) != 0
    }
    
}

extension String: Defaultable {

    /// Default Value
    public static let defaultValue = ""
    
}
