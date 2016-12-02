//
//  Extra.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

/**
 Runs a closure after a time interval
 
 - Parameters:
 - _ time: time interval
 - in queue: Queue the code should run in. (Optional. Main is the default)
 - handler: function you want to run later
 */
public func after(_ time: TimeInterval, in queue: DispatchQueue = .main, handler: @escaping () -> ()) {
    queue.asyncAfter(deadline: .now() + time) {
        handler()
    }
}

infix operator >>>

public func >>>(_ queue: DispatchQueue,_ handler: @escaping () -> ()) {
    queue.async(execute: handler)
}

public func >>>(_ time: Double, handler: @escaping () -> ()) {
    after(time, handler: handler)
}

public func >>><A, B, C>(_ funA: @escaping (A) -> (B), _ funB: @escaping (B) -> (C)) -> (A) -> (C) {
    return { input in
        input | funA | funB
    }
}

public func >>><A, B, C>(_ funA: @escaping (A) -> (B), _ funB: @escaping (B) -> (C)) -> (A) -> () {
    return { input in
        input | funA | funB**
    }
}
