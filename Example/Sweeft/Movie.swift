//
//  Movie.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Sweeft

final class Movie {
    
    let title: String
    let vote: Double
    let id: Int
    let overview: String
    var poster: UIImage?
    
    init(title: String, vote: Double, id: Int, overview: String, poster: UIImage? = nil) {
        self.title = title
        self.vote = vote
        self.id = id
        self.overview = overview
        self.poster = poster
    }
    
}

extension Movie: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let title = json["title"].string,
            let vote = json["vote_average"].double,
            let id = json["id"].int,
            let overview = json["overview"].string else {
                
                return nil
        }
        self.init(title: title, vote: vote, id: id, overview: overview)
        if let path = json["poster_path"].string {
            MovieImageAPI.shared.doDataRequest(with: .get, to: .small, arguments: ["path": path]).onSuccess { data in
                self.poster <- UIImage(data: data)
            }
        }
    }
    
}

extension Movie {
    
    func getSimilar(using api: MoviesAPI) -> Promise<[Movie], APIError> {
        return Movie.getAll(using: api, at: .similar, arguments: ["id": id], for: "results")
    }
    
}
