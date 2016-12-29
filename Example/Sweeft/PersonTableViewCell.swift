//
//  PersonTableViewCell.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/29/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class PersonTableViewCell: UITableViewCell {
    
    var person: Person? {
        didSet {
            textLabel?.text = person?.name
            imageView?.image = person?.photo
        }
    }
    
}
