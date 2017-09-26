//
//  Demo.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Sweeft

enum Demo {
    
    struct User {
        let name: String
        let id: String
    }
    
    static func other() {
        
        let handler = { ($0 + 1, $0 ** 2) }
        
        let closures = divide(closure: handler)
        
        let other = closures.0 <+> closures.1
        
        1000 => { n in
            assert(other(n) == handler(n))
        }
        
        let users = [User]()
        
        let dict = users >>= { user in
            return (user.id, user)
        }
        
        print(dict)
        
        42 => inc >>> { n in
            print("Looping for the \(n). time")
        }
        
        let array = (0..<100).array | (50..<1000)
        
        print(array)
        
        let n = -20
        
        print(n.anyRange)
        
    }
    
    static func demo() {
        
        // Here are a few examples of how to use Sweeft
        
        let array: [Int?]? = [1, 2, 3, nil, 5, nil]
        
        let res = (array ?? .empty)
            .flatMap { $0 }
            .filter { $0 & 1 == 0 }
        
        print(res)
        
        let even = !array |> { $0 & 1 == 0 }
        
        array?.withIndex => { item, index in
            // Do Stuff
        }
        
        print(even)
        
        let extra = (0...100) => { $0 ** 2 } |> { ($0 + 1).isPrime || ($0 - 1).isPrime }
        
        print(extra)
        
        let palindromePrimes = (0...1000) |> { $0.isPalindrome } |> { $0.isPrime }
        
        print(palindromePrimes)
        
        let areTherePrimes = !array ||> { $0.isPrime }
        
        print(areTherePrimes)
        
        let areAllPrimes = !array &&> { $0.isPrime }
        
        print(areAllPrimes)
        
        let sum = !array ==> (+)
        
        print(sum.?)
        
        print(24.reversed)
        
        let dict = ["String": "Other String"]
        
        print(dict.flipped)
        
        print(79.primeFactors)
        
        let item = dict.flipped.flipped | "String"
        
        print(item.?)
        
        let arrayWithDuplicates = [1, 2, 1, 5, 3]
        
        let secondToLast = arrayWithDuplicates | -2
        
        print(secondToLast.?)
        
        print(arrayWithDuplicates.noDuplicates)
        
        5.0 >>> {
            print("Other Thread Called!")
        }
        
        let dates = Date.array(of: 5)
        
        let seconds = dates.join(by: Date.string ** "ss")
        
        let two = inc ** 1
        
        print(two())
        
        /// Print all the powers of two till 42
        42 => (**) ** 2 >>> { print($0) }
        
        print(seconds)
        
        let hours = dates ==> (Date.string ** "HH") >>> { Int($0) }
        
        print(hours)
        
        dates => { item in
            print(item.string(using: "dd hh:mm a"))
        }
        
        let valueOfString = dict.match(containing: "str").?
        
        print(valueOfString)
        
        42 => inc >>> {
            print("Looping for the \($0). time")
        }
        
        print(0.factorial)
        
        print(10.factorial)
    }
    
    static func colorMap() {
        if let solution = State.color(entities: State.all) {
            print("Soluction to Map Coloring!")
            solution.forEach {
                print("\($0.key.rawValue) -> \($0.value.rawValue)")
            }
        } else {
            print("No solution available")
        }
    }
    
    static func solveQueensProblem() {
        if let solution = QueensProblem.solve() {
            print("Solution to queens problem")
            solution.forEach {
                print("Queen in x: \($0.value.x), y: \($0.value.y)")
            }
        } else {
            print("No Solution :(")
        }
    }
    
}
