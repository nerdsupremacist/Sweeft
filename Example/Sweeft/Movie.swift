//
//  Movie.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Sweeft

final class Movie: Observable {
    
    let title: String
    let vote: Double
    let id: Int
    let overview: String
    var poster: UIImage?
    
    var listeners = [Listener]()
    
    init(title: String, vote: Double, id: Int, overview: String, poster: UIImage? = nil) {
        self.title = title
        self.vote = vote
        self.id = id
        self.overview = overview
        self.poster = poster
    }
    
    func fetchImage(with path: String) {
        MovieImageAPI.fetchImage(with: path).onSuccess { image in
            self.poster = image
            self.hasChanged()
        }
    }
    
}

extension Movie: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let title = json["title"].string,
            let vote = json["vote_average"].double,
            let id = json["id"].int else {
                
                return nil
        }
        let overview = json["overview"].string ?? "No Description Available"
        self.init(title: title, vote: vote, id: id, overview: overview)
        json["poster_path"].string | fetchImage
    }
    
}

extension Movie {
    
    static func upcoming(using api: MoviesAPI = .shared) -> Response<[Movie]> {
        return getAll(using: api, at: .upcoming, for: "results")
    }
    
    static func inTheatres(using api: MoviesAPI = .shared) -> Response<[Movie]> {
        return getAll(using: api, at: .nowPlaying, for: "results")
    }
    
    static func popular(using api: MoviesAPI = .shared) -> Response<[Movie]> {
        return getAll(using: api, at: .popular, for: "results")
    }
    
    static func movie(with id: Int, using api: MoviesAPI = .shared) -> Response<Movie> {
        return get(using: api, at: .movie, arguments: ["id": id])
    }
    
    static func movies(with ids: [Int], using api: MoviesAPI = .shared) -> Response<[Movie]> {
        return api.doBulkObjectRequest(to: .movie, arguments: ids => { ["id": $0] })
    }
    
}

extension Movie {
    
    func getRoles(using api: MoviesAPI = .shared) -> Response<[Role]> {
        return Role.getAll(using: api, at: .credits, arguments: ["id": id], for: "cast")
    }
    
    func getSimilar(using api: MoviesAPI = .shared) -> Response<[Movie]> {
        return Movie.getAll(using: api, at: .similar, arguments: ["id": id], for: "results")
    }
    
}
