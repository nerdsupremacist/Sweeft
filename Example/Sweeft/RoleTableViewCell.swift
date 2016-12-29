//
//  RoleTableViewCell.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/29/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class RoleTableViewCell: UITableViewCell {
    
    var role: Role? {
        didSet {
            textLabel?.text = role?.actor.name
            detailTextLabel?.text = role?.role
            imageView?.image = role?.actor.photo
        }
    }
    
}
