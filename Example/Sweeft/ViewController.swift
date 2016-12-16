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

    @IBOutlet weak var dateLabel: UILabel!
    
    var message: String {
        if let date = LastDateOpened.value {
            let represantation = date.string(using: "dd/MM/yyyy hh:mm:ss a")
            return "You're back!!!\nLast time you opened this app was on:\n\(represantation)"
        } else {
            return "Oh! This is the first time you're using this app!\nAwesome!"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = message
        LastDateOpened.value = Date()
        
        fibonacci(50)
            .onSuccess {
                return Double($0) ** 0.5
            }
            .then {
                print($0)
                print("Item arrived")
                return $0 ** 2
            }
            .then {
                print($0)
            }
        
    }
    
    func fibonacci(_ n: Int, _ a: Int, _ b: Int) -> Int {
        if n == 0 {
            return a
        }
        return fibonacci(n - 1, a + b, a)
    }
    
    func fibonacci(_ input: Int) -> Promise<Int, NoError> {
        let promise = Promise<Int, NoError>()
        let queue = DispatchQueue(label: "fibonacciQueue")
        (queue, 5) >>> {
            let result = self.fibonacci(input, 1, 0)
            promise.success(with: result)
        }
        return promise
    }

}

