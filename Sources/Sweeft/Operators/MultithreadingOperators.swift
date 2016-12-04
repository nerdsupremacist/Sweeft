//
//  MultithreadingOperators.swift
//
//  Created by Mathias Quintero on 12/2/16.
//
//

import Foundation

infix operator >>>: FunctionArrowPrecedence

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
 - _ time: time interval
 - handler: function you want to run later
 */
public func >>>(_ time: Double, handler: @escaping () -> ()) {
    after(time, handler: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameters:
 - _ condition: queue time interval
 - handler: function you want to run later
 */
public func >>>(_ conditions: (DispatchQueue, Double), handler: @escaping () -> ()) {
    after(conditions.1, in: conditions.0, handler: handler)
}

/**
 Runs a closure after a time interval
 
 - Parameters:
 - _ c: time interval and queue
 - handler: function you want to run later
 */
public func >>>(_ c: (Double, DispatchQueue), handler: @escaping () -> ()) {
    (c.1, c.0) >>> handler
}

/**
 Chain closures. Will Chain two closures and make the output of the first one the input to the second one.
 
 - Parameters:
 - _ funA: first function
 - _ funB: second function
 */
public func >>><A, B, C>(_ funA: @escaping (A) -> (B), _ funB: @escaping (B) -> (C)) -> (A) -> (C) {
    return { input in
        input | funA | funB
    }
}

/**
 Chain closures. Will Chain two closures and make the output of the first one the input to the second one,
 but ignore the output of the second one
 
 - Parameters:
 - _ funA: first function
 - _ funB: second function
 */
public func >>><A, B, C>(_ funA: @escaping (A) -> (B), _ funB: @escaping (B) -> (C)) -> (A) -> () {
    return { input in
        input | funA | funB**
    }
}
