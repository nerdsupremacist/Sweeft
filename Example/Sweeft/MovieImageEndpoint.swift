//
//  MovieImageEndpoints.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Sweeft

enum MovieImageEndpoint: String, APIEndpoint {
    case small = "t/p/w150/{path}"
    case medium = "t/p/w300/{path}"
    case large = "t/p/w600/{path}"
}
