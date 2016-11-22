//
//  Defaultable.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

/// A Type with a Default Value
public protocol Defaultable {
    
    /// Default Value for Type
    static var defaultValue: Self { get }
}
