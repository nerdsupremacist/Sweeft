//
//  Role.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/28/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Sweeft

struct Role {
    let role: String
    let actor: Person
}

extension Role: Deserializable {
    
    init?(from json: JSON) {
        guard let role = json["character"].string,
            let actor = Person(from: json) else {
                return nil
        }
        self.init(role: role, actor: actor)
    }
    
}

extension Role: ObservableContainer {
    
    var observable: Person {
        return actor
    }
    
}

extension Role {
    
    func role(called role: String, for id: Int, using api: MoviesAPI = .shared) -> Role.Result {
        return Person.person(with: id, using: api).nested(Role.init ** role)
    }
    
}
