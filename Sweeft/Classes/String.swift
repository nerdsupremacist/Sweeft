//
//  Swift.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

extension String {
    
    var isPalindrome: Bool {
        if characters.count < 2 {
            return true
        }
        if characters.first != characters.last {
            return false
        }
        let range = index(after: startIndex)..<index(before: endIndex)
        return substring(with: range).isPalindrome
    }
    
    func date(using format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
}

extension String {
    
    func matches(pattern: String, options: NSRegularExpression.Options = []) throws -> Bool {
        let regex = try NSRegularExpression(pattern: pattern, options: options)
        return regex.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: 0.distance(to: utf16.count))) != 0
    }
    
}

extension String: Defaultable {
    
    static let defaultValue = ""
    
}
