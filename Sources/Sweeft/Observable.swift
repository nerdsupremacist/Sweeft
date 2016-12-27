//
//  Observable.swift
//  Pods
//
//  Created by Mathias Quintero on 12/26/16.
//
//

import Foundation

public protocol Observable {
    var listeners: [Listener] { get set }
}

public extension Observable {
    
    typealias ListeningHandler = (Self) -> ()
    typealias Listener = (handler: ListeningHandler, queue: DispatchQueue)
    
    public mutating func onChange(do handler: @escaping (Self) -> (), completionQueue: DispatchQueue = .main) {
        // Add listener somehow
        listeners.append((handler, completionQueue))
    }
    
    public func hasChanged() {
        listeners => { (listener: Listener) in
            listener.queue >>> {
                 listener.handler(self)
            }
        }
    }
    
}
