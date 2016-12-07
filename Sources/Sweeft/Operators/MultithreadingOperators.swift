//
//  MultithreadingOperators.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

infix operator >>>: MultiplicationPrecedence

/**
 Runs a closure in a specific queue
 
 - Parameters:
    - queue: Queue the code should run in.
    - handler: function you want to run later
 */
public func >>>(_ queue: DispatchQueue,_ handler: @escaping () -> ()) {
    queue.async(execute: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameters:
    - time: time interval
    - handler: function you want to run later
 */
public func >>>(_ time: Double, handler: @escaping () -> ()) {
    after(time, handler: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameters:
    - conditions: queue time interval
    - handler: function you want to run later
 */
public func >>>(_ conditions: (DispatchQueue, Double), handler: @escaping () -> ()) {
    after(conditions.1, in: conditions.0, handler: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameters:
    - c: time interval and queue
    - handler: function you want to run later
 */
public func >>>(_ c: (Double, DispatchQueue), handler: @escaping () -> ()) {
    (c.1, c.0) >>> handler
}

/**
 Chain closures. Will Chain two closures and make the output of the first one the input to the second one.
 
 - Parameters:
    - funA: first function
    - funB: second function
 */
public func >>><A, B, C>(_ funA: @escaping (A) -> (B), _ funB: @escaping (B) -> (C)) -> (A) -> (C) {
    return { input in
        input | funA | funB
    }
}
