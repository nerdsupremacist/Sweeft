//
//  SearchResult.swift
//  Sweeft
//
//  Created by Mathias Quintero on 2/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Sweeft

enum SearchResult {
    case movie(value: Movie)
    case person(value: Person)
}

extension SearchResult: Deserializable {
    
    init?(from json: JSON) {
        let inits: [String : (JSON) -> SearchResult?] = [
            "person": Person.init >>> !SearchResult.person,
            "movie": Movie.init >>> !SearchResult.movie,
        ]
        
        guard let type = json["media_type"].string, let value = inits[type]?(json) else {
            return nil
        }
        self = value
    }
    
}
