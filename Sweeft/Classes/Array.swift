//
//  Arrays.swift
//  Swiftoids
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation
extension Array {
    
    func array(withFirst number: Int) -> [Element] {
        if number > count {
            return self
        }
        return (0..<number).map { self[$0] }
    }
    
    func array(withLast number: Int) -> [Element] {
        return self.reversed().array(withFirst: number).reversed()
    }
    
    func sum(_ mapper: (Element) -> (Double)) -> Double {
        return self.map(mapper).reduce(0, +)
    }
    
    func sum(_ mapper: (Element) -> (Int)) -> Int {
        return Int(sum(mapper))
    }
    
}

extension Array {
    
    static var defaultValue: [Element] {
        return []
    }
    
}
