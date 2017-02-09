//
//  MovieDBEndpoint.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Sweeft

enum MoviesEndpoint: String, APIEndpoint {
    case popular = "movie/popular"
    case upcoming = "movie/upcoming"
    case nowPlaying = "movie/now_playing"
    case movie = "movie/{id}"
    case credits = "movie/{id}/credits"
    case images = "movie/{id}/images"
    case videos = "movie/{id}/videos"
    case similar = "movie/{id}/similar"
    case person = "person/{id}"
    case moviesForPerson = "person/{id}/movie_credits"
    case search = "search/multi"
}
