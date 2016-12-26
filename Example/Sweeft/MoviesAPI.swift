//
//  MovieDB.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Sweeft

struct MoviesAPI: API {
    
    typealias Endpoint = MoviesEndpoint
    
    static var shared = MoviesAPI()
    static var baseURL = "https://api.themoviedb.org/3"
    
    let apiKey: String
    
    var baseQueries: [String : String] {
        return [
            "api_key": apiKey
        ]
    }
    
}

extension MoviesAPI {
    
    init() {
        self.apiKey = "18ec732ece653360e23d5835670c47a0"
    }
    
}
