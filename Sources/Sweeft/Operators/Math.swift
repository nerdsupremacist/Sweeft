//
//  Functional.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

infix operator **

/// Exponentiates
public func **(_ a: Double, _ b: Double) -> Double {
    return pow(a, b)
}

/// Exponentiates
public func **(_ a: Int, _ b: Int) -> Int {
    return Int(Double(a) ** Double(b))
}

/// Remainder Operator
public func %(_ a: Double, _ b: Double) -> Double {
    return a.remainder(dividingBy: b)
}

prefix operator |

/// Will return the abs
public prefix func |(_ value: Int) -> Int {
    return abs(value)
}

infix operator ~~

/// Will say if a string contains a match for regex
public func ~~(left: String, right: String) -> Bool {
    return .?(try? left.matches(pattern: right, options: []))
}
