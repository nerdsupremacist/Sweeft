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

public struct OAuthManager<V: APIEndpoint>: API {
    
    public typealias Endpoint = V
    public let baseURL: String
    public let clientID: String
    public let secret: String
    public let useBasicHttp: Bool
    public let useJSON: Bool
    
    public init(baseURL: String, clientID: String, secret: String, useBasicHttp: Bool = true, useJSON: Bool = false) {
        self.baseURL = baseURL
        self.clientID = clientID
        self.secret = secret
        self.useBasicHttp = useBasicHttp
        self.useJSON = useJSON
    }
    
    func auth() -> Auth {
        if useBasicHttp {
            return BasicAuth(username: clientID, password: secret)
        } else {
            return NoAuth.standard
        }
    }
    
    func body(username: String, password: String, scope: String?) -> [String:String] {
        var dict = [
            "grant_type": "password",
            "username": username,
            "password": password
        ]
        if !useBasicHttp {
            dict["client_id"] = clientID
            dict["client_secret"] = secret
        }
        dict["scope"] = scope
        return dict
    }
    
    func body(auth: OAuth) -> [String:String] {
        var dict = [
            "grant_type": "refresh_token",
            ]
        if !useBasicHttp {
            dict["client_id"] = clientID
            dict["client_secret"] = secret
        }
        dict["refresh_token"] = auth.refreshToken
        return dict
    }
    
    private func jsonRequest(to endpoint: Endpoint, auth: Auth, body: [String: String]) -> OAuth.Result {
        return doObjectRequest(with: .post,
                               to: endpoint,
                               auth: auth,
                               body: body.mapValues({ $0.json }).json)
    }
    
    private func queriedRequest(to endpoint: Endpoint, auth: Auth, body: [String:String]) -> OAuth.Result {
        return doDataRequest(with: .post, to: endpoint, queries: body, auth: auth).nested { data, promise in
            if let auth = OAuth(data: data) {
                promise.success(with: auth)
            } else {
                promise.error(with: .invalidData(data: data))
            }
        }
    }
    
    public func refresh(at endpoint: Endpoint, with auth: OAuth) -> OAuth.Result {
        let body = self.body(auth: auth)
        let auth = self.auth()
        if useJSON {
            return jsonRequest(to: endpoint, auth: auth, body: body)
        } else {
            return queriedRequest(to: endpoint, auth: auth, body: body)
        }
    }
    
    public func authenticate(at endpoint: Endpoint, username: String, password: String, scope: String...) -> OAuth.Result {
        let auth = self.auth()
        let scope = scope.isEmpty ? nil : scope.join(with: " ")
        let body = self.body(username: username, password: password, scope: scope)
        if useJSON {
            return jsonRequest(to: endpoint, auth: auth, body: body)
        } else {
            return queriedRequest(to: endpoint, auth: auth, body: body)
        }
    }
    
}

public extension API {
    
    func oauthManager(clientID: String, secret: String, useBasicHttp: Bool = true, useJSON: Bool = false) -> OAuthManager<Self.Endpoint> {
        return OAuthManager(baseURL: self.baseURL, clientID: clientID, secret: secret, useBasicHttp: useBasicHttp, useJSON: useJSON)
    }
    
}

public struct OAuth: Auth {
    
    fileprivate let token: String
    fileprivate let tokenType: String
    fileprivate let refreshToken: String?
    fileprivate let expirationDate: Date?
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else {
            return false
        }
        return expirationDate < .now
    }
    
    public func refresh() {
        
    }
    
    public func apply(to request: inout URLRequest) {
        if isExpired {
            refresh()
        }
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

extension OAuth: StatusSerializable {
    
    public init?(from status: [String : Any]) {
        guard let token = status["token"] as? String,
            let tokenType = status["tokenType"] as? String else {
                return nil
        }
        self.init(token: token, tokenType: tokenType, refreshToken: (status["refresh"] as? String),
                  expirationDate: (status["expiration"] as? String)?.date())
    }
    
    public var serialized: [String : Any] {
        var dict = [
            "token": token,
            "tokenType": tokenType
        ]
        dict["refresh"] <- refreshToken
        dict["expiration"] <- expirationDate?.string()
        return dict
    }
    
}

extension OAuth {
    
    public func store(using key: String) {
        OAuthStatus.key = OAUTHStatusKey(name: key)
        OAuthStatus.value = self
    }
    
    public static func stored(with key: String) -> OAuth? {
        OAuthStatus.key = OAUTHStatusKey(name: key)
        return OAuthStatus.value
    }
    
}

struct OAUTHStatusKey: StatusKey {
    let name: String
    
    var rawValue: String {
        return "OAUTH-\(name)"
    }
}

struct OAuthStatus: OptionalStatus {
    typealias Value = OAuth
    static var key = OAUTHStatusKey(name: "shared")
}
