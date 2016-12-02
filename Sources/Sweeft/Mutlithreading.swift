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

infix operator >>

func >>(_ queue: DispatchQueue,_ handler: @escaping () -> ()) {
    queue.async(execute: handler)
}

func >>(_ time: TimeInterval, handler: @escaping () -> ()) {
    after(time, handler: handler)
}
