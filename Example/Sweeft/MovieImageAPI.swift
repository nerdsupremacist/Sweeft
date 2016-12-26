//
//  MovieImageAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Sweeft

struct MovieImageAPI: API {
    typealias Endpoint = MovieImageEndpoint
    static var shared = MovieImageAPI()
    static var baseURL = "https://image.tmdb.org/"
}
