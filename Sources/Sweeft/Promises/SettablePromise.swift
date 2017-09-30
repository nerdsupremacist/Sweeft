//
//  SettablePromise.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/30/17.
//

import Foundation

class SelfSettingPromise<T, E: Error>: Promise<T, E> {
    
    private(set) var setter: Setter!
    
    init(completionQueue: DispatchQueue = .global()) {
        var setter: Setter!
        super.init(completionQueue: completionQueue) { setter = $0 }
        self.setter = setter
    }
    
}
