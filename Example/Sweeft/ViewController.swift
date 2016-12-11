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
        
        Demo.demo()
        
    }

}

