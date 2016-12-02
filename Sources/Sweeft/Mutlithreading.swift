//
//  Multithreading.swift
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
public func after(_ time: TimeInterval = 0.0, in queue: DispatchQueue = .main, handler: @escaping () -> ()) {
    queue.asyncAfter(deadline: .now() + time) {
        handler()
    }
}
