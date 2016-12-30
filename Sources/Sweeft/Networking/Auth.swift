//
//  Auth.swift
//  Pods
//
//  Created by Mathias Quintero on 12/29/16.
//
//

import Foundation

public protocol Auth {
    func apply(to request: inout URLRequest)
}

public struct NoAuth: Auth {
    
    static let standard = NoAuth()
    
    public func apply(to request: inout URLRequest) {
        // Do Nothing
    }
    
}

public struct BasicAuth {
    
    let username: String
    let password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
}

extension BasicAuth: Auth {
    
    public func apply(to request: inout URLRequest) {
        let string = ("\(username):\(password)".base64Encoded).?
        let auth = "Basic \(string)"
        request.addValue(auth, forHTTPHeaderField: "Authorization")
    }
    
}
