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
    let date: Date
    var poster: UIImage?
    
    var listeners = [Listener]()
    
    init(title: String, vote: Double, id: Int, overview: String, date: Date, poster: UIImage? = nil) {
        self.title = title
        self.vote = vote
        self.id = id
        self.overview = overview
        self.date = date
        self.poster = poster
    }
    
    func fetchImage(with path: String) {
        MovieImageAPI.fetchImage(with: path).onSuccess { image in
            self.poster = image
            self.hasChanged()
        }
    }
    
    /// Says whether or not a movie was released close enough to the date for it to be relevant.
    func isRelevant(for date: Date) -> Bool {
        return abs((date - self.date).weeks) <= 12
    }
    
}

extension Movie: ValueComparable {
    
    var comparable: Double {
        return vote
    }
    
}

extension Movie: Hashable {
    
    var hashValue: Int {
        return id
    }
    
}

func ==(_ lhs: Movie, _ rhs: Movie) -> Bool {
    return lhs.id == rhs.id
}

extension Movie: Deserializable {
    
    convenience init?(from json: JSON) {
        guard let title = json["title"].string,
            let vote = json["vote_average"].double,
            let overview = json["overview"].string,
            let id = json["id"].int,
            let date = json["release_date"].date(using: "yyyy-MM-dd") else {
                
                return nil
        }
        self.init(title: title, vote: vote, id: id, overview: overview, date: date)
        json["poster_path"].string | fetchImage
    }
    
}

extension Movie {
    
    static func movie(with id: Int, using api: MoviesAPI = .shared) -> Movie.Result {
        return get(using: api, at: .movie, arguments: ["id": id])
    }
    
    static func movies(with ids: [Int], using api: MoviesAPI = .shared) -> Movie.Results {
        return api.doBulkObjectRequest(to: .movie, arguments: ids => { ["id": $0] })
    }
    
    static func featured(using api: MoviesAPI = .shared) -> Movie.Results {
        return api.doFlatBulkObjectRequest(to: [.nowPlaying, .upcoming, .popular],
                                           at: ["results"])
                    .nested { $0 |> { $0.vote >= 5.0 } }
                    .nested { $0 |> Movie.isRelevant ** Date() }
                    .nested { $0.noDuplicates }
    }
    
}

extension Movie {
    
    func getRoles(using api: MoviesAPI = .shared) -> Role.Results {
        return Role.getAll(using: api, at: .credits, arguments: ["id": id], for: "cast")
    }
    
    func getSimilar(using api: MoviesAPI = .shared) -> Movie.Results {
        return Movie.getAll(using: api, at: .similar, arguments: ["id": id], for: "results")
    }
    
}
