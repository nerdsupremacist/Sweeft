//
//  Functional.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

//: Exponent operator
infix operator **

func **(_ a: Double, _ b: Double) -> Double {
    return pow(a, b)
}

func **(_ a: Int, _ b: Int) -> Int {
    return Int(Double(a) ** Double(b))
}

//: Remainder Operator
func %(_ a: Double, _ b: Double) -> Double {
    return a.remainder(dividingBy: b)
}

//: Will return the abs
prefix operator |

prefix func |(_ value: Int) -> Int {
    return abs(value)
}

// Will say if a string contains a match for regex
infix operator ~~

func ~~ (left: String, right: String) -> Bool {
    return .?(try? left.matches(pattern: right, options: []))
}
