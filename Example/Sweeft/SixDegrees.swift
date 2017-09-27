//
//  SixDegrees.swift
//  Sweeft
//
//  Created by Mathias Quintero on 2/24/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Sweeft

enum SixDegreesNode: HashableNode, SimpleNode {
    
    case actor(id: Int)
    case movie(id: Int)
    
    var id: Int {
        switch self {
        case .actor(let id):
            return id
        case .movie(let id):
            return id
        }
    }
    
    var other: (Int) -> SixDegreesNode {
        switch self {
        case .movie:
            return SixDegreesNode.actor
        case .actor:
            return SixDegreesNode.movie
        }
    }
    
    var endpoint: MoviesEndpoint {
        switch self {
        case .actor:
            return .moviesForPerson
        case .movie:
            return .credits
        }
    }
    
    func neighbourIdentifiers() -> Promise<[SixDegreesNode], AnyError> {
        let api = MoviesAPI.shared
        return api.get(endpoint, arguments: ["id": id])
            .generalizeError()
            .map { json -> [SixDegreesNode] in
                let ids = json["cast"].array ==> { $0["id"].int }
                return ids => self.other
        }
    }
}

extension SixDegreesNode {
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static func ==(lhs: SixDegreesNode, rhs: SixDegreesNode) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension SixDegreesNode: Deserializable {
    
    init?(from json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        self = .actor(id: id)
    }
    
}
