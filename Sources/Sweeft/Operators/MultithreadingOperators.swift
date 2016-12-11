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
 
 - Parameter queue: Queue the code should run in.
 - Parameter handler: function you want to run later
 
 */
public func >>>(_ queue: DispatchQueue,_ handler: @escaping () -> ()) {
    queue.async(execute: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameter time: time interval
 - Parameter handler: function you want to run later
 
 */
public func >>>(_ time: Double, handler: @escaping () -> ()) {
    after(time, handler: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameter conditions: queue and time interval
 - Parameter handler: function you want to run later
 
 */
public func >>>(_ conditions: (DispatchQueue, Double), handler: @escaping () -> ()) {
    after(conditions.1, in: conditions.0, handler: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameter c: time interval and queue
 - Parameter handler: function you want to run later
 
 */
public func >>>(_ c: (Double, DispatchQueue), handler: @escaping () -> ()) {
    (c.1, c.0) >>> handler
}

/**
 Chain closures. Will Chain two closures and make the output of the first one the input to the second one.
 
 - Parameter funA: first function
 - Parameter funB: second function
 
 */
public func >>><A, B, C>(_ funA: @escaping (A) -> (B), _ funB: @escaping (B) -> (C)) -> (A) -> (C) {
    return { input in
        input | funA | funB
    }
}
