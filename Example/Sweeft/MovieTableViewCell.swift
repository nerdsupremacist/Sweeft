//
//  MovieTableViewCell.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    var movie: Movie? {
        didSet {
            self.textLabel?.text = movie?.title
            if let vote = movie?.vote {
                self.detailTextLabel?.text = vote.description
            } else {
                self.detailTextLabel?.text = "Not Rated"
            }
            self.imageView?.image = movie?.poster
        }
    }
    
}
