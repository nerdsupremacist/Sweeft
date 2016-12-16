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
    
    static func inc(_ n: Int) -> Int {
        return n + 1
    }
    
    static func other() {
        
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
        
    }
    
    static func demo() {
        
        // Here are a few examples of how to use Sweeft
        
        let array: [Int?]? = [1, 2, 3, nil, 5, nil]
        
        let res = (array ?? [])
            .flatMap { $0 }
            .filter { $0 & 1 == 0 }
        
        print(res)
        
        let even = !array |> { $0 & 1 == 0 }
        
        array => { item, index in
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
        
        let dates = Date.array(ofSize: 5)
        
        let seconds = dates.join { $0.string(using: "ss") }
        
        print(seconds)
        
        let hours = dates ==> { $0.string(using: "HH") } >>> { Int($0) }
        
        print(hours)
        
        dates => { item in
            print(item.string(using: "dd hh:mm a"))
        }
        
        let valueOfString = dict.match(containing: "str").?
        
        print(valueOfString)
        
        42 => {
            $0 + 1
        } >>> {
            print("Looping for the \($0). time")
        }
    }
    
}
