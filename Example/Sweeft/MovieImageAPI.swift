//
//  MovieImageAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Sweeft

extension UIImage: DataRepresentable { }

struct MovieImageAPI: API {
    
    typealias Endpoint = MovieImageEndpoint
    static var shared = MovieImageAPI()
    
    let baseURL = "https://image.tmdb.org/"
    
    func fetchImage(with path: String) -> UIImage.Result {
        return doRepresentedRequest(to: .small, arguments: ["path": path])
    }
    
    static func fetchImage(using api: MovieImageAPI = .shared, with path: String) -> UIImage.Result {
        return api.fetchImage(with: path)
    }
}
