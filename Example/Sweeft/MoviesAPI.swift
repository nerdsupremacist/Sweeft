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
    
    let baseURL: String
    
    let apiKey: String
    
    var baseQueries: [String : String] {
        return [
            "api_key": apiKey
        ]
    }
    
    init(version: Int = 3, apiKey: String) {
        self.baseURL = "https://api.themoviedb.org/\(version)"
        self.apiKey = apiKey
    }
    
}

extension MoviesAPI {
    
    init() {
        self.init(apiKey: "18ec732ece653360e23d5835670c47a0")
    }
    
}

extension MoviesAPI {
    
    func search(for query: String) -> SearchResult.Results {
        return SearchResult.getAll(using: self, at: .search, queries: ["query": query], for: "results")
    }
    
    static func search(for query: String) -> SearchResult.Results {
        return shared.search(for: query)
    }
    
}
