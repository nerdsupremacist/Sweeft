//
//  Person.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Sweeft

final class Person: Observable {
    
    let id: Int
    let name: String
    var photo: UIImage?
    
    var listeners = [Listener]()
    
    init(id: Int, name: String, photo: UIImage? = nil) {
        self.id = id
        self.name = name
        self.photo = photo
    }
    
    func fetchImage(with path: String) {
        MovieImageAPI.fetchImage(with: path).onSuccess { image in
            self.photo = image
            self.hasChanged()
        }
    }
    
}

extension Person: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let id = json["id"].int,
            let name = json["name"].string else {
                return nil
        }
        self.init(id: id, name: name)
        json["profile_path"].string | fetchImage
    }
    
}

extension Person {
    
    static func person(with id: Int, using api: MoviesAPI) -> Person.Result {
        return Person.get(using: api, at: .person, arguments: ["id": id])
    }
    
    static func people(with ids: [Int], using api: MoviesAPI) -> Person.Results {
         return api.doBulkObjectRequest(to: .person, arguments: ids => { ["id": $0] })
    }
    
}

extension Person {
    
    func getMovies(using api: MoviesAPI = .shared) -> Movie.Results {
        return api.get(.moviesForPerson, arguments: ["id": id])
            .onSuccess { json -> Response<[Movie]> in
                let ids = json["cast"].array ==> { $0["id"].int } | 25.range
                return Movie.movies(with: ids, using: api)
            }
            .future
    }
    
}
