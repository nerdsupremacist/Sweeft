//
//  ViewController.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/20/2016.
//  Copyright (c) 2016 Mathias Quintero. All rights reserved.
//

import UIKit
import Sweeft

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let array: [Int?]? = [1, 2, 3, nil, 5, nil]
        
        let res = (array ?? [])
            .flatMap { $0 }
            .filter { $0 & 1 == 0 }
        
        print(res)
        
        let even = !array.? |> { $0 & 1 == 0 }
        
        print(even)
        
        let extra = (0...100).array => { $0 ** 2 } |> { ($0 + 1).isPrime || ($0 - 1).isPrime }
        
        print(extra)
        
        let palindromePrimes = (0...1000).array |> { $0.isPalindrome } |> { $0.isPrime }
        
        print(palindromePrimes)
        
        print(24.reversed)
        
        5.0 >>> {
            print("Other Thread Called!")
        }
        
    }

}

