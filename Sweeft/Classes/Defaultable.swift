//
//  Defaultable.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

protocol Defaultable {
    static var defaultValue: Self { get }
}
