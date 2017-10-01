//
//  File.swift
//  Pods
//
//  Created by Mathias Quintero on 2/27/17.
//
//

import Foundation

public struct OAuthManager<V: APIEndpoint>: API, Codable {
    
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
    
    func body(with grant: Grant) -> [String:String] {
        var dict = grant.dict.dictionaryWithoutOptionals(byDividingWith: id)
        if !useBasicHttp {
            dict["client_id"] = clientID
            dict["client_secret"] = secret
        }
        return dict
    }
    
    private func jsonRequest(to endpoint: Endpoint, auth: Auth, body: [String: String]) -> Response<OAuth.Token> {
        return doDecodableRequest(with: .post,
                                  to: endpoint,
                                  auth: auth,
                                  body: body.mapValues({ $0.json }).json.data)
    }
    
    private func queriedRequest(to endpoint: Endpoint, auth: Auth, body: [String:String]) -> Response<OAuth.Token> {
        return doDecodableRequest(with: .post, to: endpoint, queries: body, auth: auth)
    }
    
    private func applyRefresher(to token: OAuth.Token, with endpoint: Endpoint) -> OAuth {
        let refresher = OAuthManager<OAuthEndpoint>(baseURL: baseURL,
                                                    clientID: clientID,
                                                    secret: secret,
                                                    useBasicHttp: useBasicHttp,
                                                    useJSON: useJSON)
        
        let endpoint = OAuthEndpoint(rawValue: endpoint.rawValue)
        return OAuth(token: token,
                     updated: .now,
                     manager: refresher,
                     endpoint: endpoint)
    }
    
    private func requestAuth(to endpoint: Endpoint, with grant: Grant) -> Response<OAuth.Token> {
        let auth = self.auth()
        let body = self.body(with: grant)
        if useJSON {
            return jsonRequest(to: endpoint, auth: auth, body: body)
        } else {
            return queriedRequest(to: endpoint, auth: auth, body: body)
        }
    }
    
    private func requestAuth(to endpoint: Endpoint, with grant: Grant) -> Response<OAuth> {
        return requestAuth(to: endpoint, with: grant).map(applyRefresher <** endpoint)
    }
    
    private func authenticate(at endpoint: Endpoint, with json: JSON) -> Response<OAuth> {
//        if let auth = OAuth(from: json) {
//            return .successful(with: auth)
//        }
//        if let authorizationCode = json["code"].string {
//            return authenticate(at: endpoint, authorizationCode: authorizationCode)
//        }
//        return .errored(with: .mappingError(json: json))
        fatalError()
    }
    
    func refresh(at endpoint: Endpoint, with token: OAuth.Token) -> Response<OAuth.Token> {
        return requestAuth(to: endpoint, with: .refreshToken(token: token.refreshToken))
    }
    
    public func authenticate(at endpoint: Endpoint, callback url: URL) -> Response<OAuth> {
        if let fragment = url.fragment {
            let json = JSON(fragment: fragment)
            return authenticate(at: endpoint, with: json)
        } else if let query = url.query {
            let json = JSON(fragment: query)
            return authenticate(at: endpoint, with: json)
        }
        return .errored(with: .cannotPerformRequest)
    }
    
    public func authenticate(at endpoint: Endpoint, authorizationCode code: String) -> Response<OAuth> {
        return requestAuth(to: endpoint, with: .authorizationCode(code: code))
    }
    
    public func authenticate(at endpoint: Endpoint,
                             username: String,
                             password: String,
                             scope: [String] = []) -> Response<OAuth> {
        
        let scope = scope.isEmpty ? nil : scope.join(with: " ")
        let grant: Grant = .password(username: username, password: password, scope: scope)
        return requestAuth(to: endpoint, with: grant)
    }
    
}

struct OAuthEndpoint: APIEndpoint, Codable {
    let rawValue: String
}
