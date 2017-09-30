//
//  Multithreading.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

/**
 Runs a closure after a time interval
 
 - Parameter time: time interval
 - Parameter queue: Queue the code should run in. (Optional. Main is the default)
 - Parameter handler: function you want to run later
 */
public func after(_ time: TimeInterval = 0.0, in queue: DispatchQueue = .main, handler: @escaping () -> ()) {
    queue.asyncAfter(deadline: .now() + time) {
        handler()
    }
}


public func async<T, E: GenerizableError>(runQueue: DispatchQueue,
                                          completionQueue: DispatchQueue = .main,
                                          _ handle: @escaping () throws -> T) -> Promise<T, E> {
    
    return .new(completionQueue: completionQueue) { setter in
        runQueue >>> {
            do {
                let result = try handle()
                setter.success(with: result)
            } catch let error {
                let error = error as? E ?? E(error: error)
                setter.error(with: error)
            }
        }
    }
}

public func async<T, E: GenerizableError>(qos: DispatchQoS = .background,
                                          completionQueue: DispatchQueue = .main,
                                          _ handle: @escaping () throws -> T) -> Promise<T, E> {
    
    let queue = DispatchQueue(label: String(describing: qos), qos: qos)
    return async(runQueue: queue, completionQueue: completionQueue, handle)
}

public func async<I, T, E: GenerizableError>(qos: DispatchQoS = .background,
                                             completionQueue: DispatchQueue = .main,
                                             _ handle: @escaping (I) -> T) -> (I) -> Promise<T, E> {
    
    return { async(qos: qos, completionQueue: completionQueue, handle ** $0) }
}
