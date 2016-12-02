//
//  Range.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation
public extension CountableRange {
    
    /// Will turn into an array
    var array: [Bound] {
        return self.map { $0 }
    }
    
}
