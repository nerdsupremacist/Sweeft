//
//  QueensProblem.swift
//  Sweeft
//
//  Created by Mathias Quintero on 2/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Sweeft

enum QueensProblem {
    
    typealias Coordinate = (x: Int, y: Int)
    
    static func areClear(a: Coordinate, b: Coordinate) -> Bool {
        return !(a.x == b.x || a.y == b.y || abs(a.x - b.x) == abs(a.y - b.y))
    }
    
    static func solve() -> [Int:Coordinate]? {
        let constraints = 8.anyRange.flatMap { a in
            return 8.range |> { $0 != a } => { b in
                return Constraint<Int, Coordinate>.binary(a, b, Constraint: areClear)
            }
        }
        let variables = 8.range => { x in (name: x, possible: 8.range => { (x: x, y: $0) }) }
        let csp = CSP<Int, Coordinate>(variables: variables, constraints: constraints)
        return csp.solution()
    }
    
}
