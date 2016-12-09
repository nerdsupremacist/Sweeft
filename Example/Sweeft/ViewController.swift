//
//  ViewController.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/20/2016.
//  Copyright (c) 2016 Mathias Quintero. All rights reserved.
//

import UIKit
import Sweeft

let someOptional: Int? = nil
let someDefault = 0

let answer = someOptional ?? someDefault

let firstName: String? = "My Name"
let lastName: String? = "My Lastname"

let id: Int? = 123456789
let favoriteNumber: Int? = 42
let age: Int? = 20
let meaningOfLife: Int? = 42

struct Person {
    let firstName: String
    let lastName: String
    let id: Int
    let favoriteNumber: Int
    let age: Int
    let meaningOfLife: Int
}



func instantiate() {
    let me = Person(firstName: firstName.?,
                lastName: lastName.?,
                id: id.?,
                favoriteNumber: favoriteNumber.?,
                age: age.?,
                meaningOfLife: meaningOfLife ?? 42)
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Here are a few examples of how to use Sweeft
        
        let array: [Int?]? = [1, 2, 3, nil, 5, nil]
        
        let res = (array ?? [])
            .flatMap { $0 }
            .filter { $0 & 1 == 0 }
        
        print(res)
        
        let even = !array.? |> { $0 & 1 == 0 }
        
        array.? => { item, index in
            // Do Stuff
        }
        
        print(even)
        
        let extra = (0...100) => { $0 ** 2 } |> { ($0 + 1).isPrime || ($0 - 1).isPrime }
        
        print(extra)
        
        let palindromePrimes = (0...1000) |> { $0.isPalindrome } |> { $0.isPrime }
        
        print(palindromePrimes)
        
        let sum = !array.? ==> (+)
        
        print(sum.?)
        
        print(24.reversed)
        
        let dict = ["String": "Other String"]
        
        print(dict.flipped)
        
        print(79.primeFactors)
        
        let item = dict.flipped.flipped | "String"
        
        print(item.?)
        
        let arrayWithDuplicates = [1, 2, 1, 2, 3]
        
        let secondToLast = arrayWithDuplicates | -2
        
        print(secondToLast.?)
        
        print(arrayWithDuplicates.noDuplicates)
        
        5.0 >>> {
            print("Other Thread Called!")
        }
        
        let dates = Date.array(ofSize: 5)
        
        let seconds = dates.join { $0.string(with: "ss") }
        
        print(seconds)
        
        let hours = dates ==> { $0.string(with: "HH") } >>> { Int($0) }
        
        print(hours)
        
    }

}

