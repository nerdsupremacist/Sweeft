//
//  DefaultStatusKey.swift
//  Pods
//
//  Created by Mathias Quintero on 12/11/16.
//
//

import Foundation

public protocol StatusKey {
    var rawValue: String { get }
}

extension StatusKey {
    
    var userDefaultsKey: String {
        return String(describing: Self.self) + "." + rawValue
    }
    
}
