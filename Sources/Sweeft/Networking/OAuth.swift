//
//  OAuth.swift
//  Pods
//
//  Created by Mathias Quintero on 1/4/17.
//
//

import Foundation

public struct OAuthEndpoint: APIEndpoint {
    public let rawValue: String
}

public struct OAuthManager: API {
    
    public typealias Endpoint = OAuthEndpoint
    public let baseURL: String
    public let clientID: String
    public let secret: String
    
    public init(baseURL: String, clientID: String, secret: String) {
        self.baseURL = baseURL
        self.clientID = clientID
        self.secret = secret
    }
    
    func body(username: String, password: String, scope: String?) -> JSON {
        var dict = [
            "grant_type": "password",
            "client_id": clientID,
            "client_secret": secret,
            "username": username,
            "password": password
        ]
        dict["scope"] <- scope
        return .dict(dict >>= mapLast(with: JSON.init))
    }
    
    public func authenticate(at url: String, username: String, password: String, scope: String...) -> OAuth.Result {
        let endpoint = OAuthEndpoint(rawValue: url)
        let auth = BasicAuth(username: username, password: password)
        let scope = scope.isEmpty ? nil : scope.join(with: " ")
        let body = self.body(username: username, password: password, scope: scope)
        return doObjectRequest(with: .post, to: endpoint, auth: auth, body: body)
    }
    
}

public struct OAuth: Auth {
    
    fileprivate let token: String
    fileprivate let tokenType: String
    fileprivate let refreshToken: String?
    fileprivate let expirationDate: Date?
    
    public func apply(to request: inout URLRequest) {
        request.addValue("\(tokenType) \(token)", forHTTPHeaderField: "Authorization")
    }
    
}

extension OAuth: Deserializable {
    
    public init?(from json: JSON) {
        guard let token = json["access_token"].string,
            let tokenType = json["token_type"].string else {
                return nil
        }
        self.init(token: token, tokenType: tokenType,
                  refreshToken: json["refresh_token"].string, expirationDate: nil)
    }
    
}
