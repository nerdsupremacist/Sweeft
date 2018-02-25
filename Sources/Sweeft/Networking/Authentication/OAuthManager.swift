//
//  File.swift
//  Pods
//
//  Created by Mathias Quintero on 2/27/17.
//
//

import Foundation

public protocol RefreshPerformer: class {
    func refresh(using refreshToken: String?) -> Response<OAuth.Token>
}

public protocol OAuthCabableAPI: API, RefreshPerformer {
    
    var authEndpoint: Endpoint { get }
    var refreshEndpoint: Endpoint { get }
    
    var clientID: String { get }
    var clientSecret: String { get }
    
    var useBasicHttp: Bool { get }
    var useJSON: Bool { get }
    
    func store(token: OAuth)
}

// MARK: Default Implementations

extension OAuthCabableAPI {
    
    var refreshEndpoint: Endpoint {
        return authEndpoint
    }
    
    var useBasicHttp: Bool {
        return true
    }
    
    var useJSON: Bool {
        return true
    }
    
}

// MARK: Helper Request and other methods

extension OAuthCabableAPI {
    
    private func authRequestAuth() -> Auth {
        if useBasicHttp {
            return BasicAuth(username: clientID, password: clientSecret)
        } else {
            return NoAuth.standard
        }
    }
    
    private func body(with grant: Grant) -> [String : String] {
        var dict = grant.dict.dictionaryWithoutOptionals(byDividingWith: id)
        if !useBasicHttp {
            dict["client_id"] = clientID
            dict["client_secret"] = clientSecret
        }
        return dict
    }
    
    private func jsonRequest(to endpoint: Endpoint, auth: Auth, body: [String : String]) -> Response<OAuth.Token> {
        return doDecodableRequest(with: .post,
                                  to: endpoint,
                                  auth: auth,
                                  body: body)
    }
    
    private func queriedRequest(to endpoint: Endpoint, auth: Auth, body: [String : String]) -> Response<OAuth.Token> {
        return doDecodableRequest(with: .post, to: endpoint, queries: body, auth: auth)
    }
    
    fileprivate func requestAuth(to endpoint: Endpoint, with grant: Grant) -> Response<OAuth.Token> {
        let auth = self.authRequestAuth()
        let body = self.body(with: grant)
        if useJSON {
            return jsonRequest(to: endpoint, auth: auth, body: body)
        } else {
            return queriedRequest(to: endpoint, auth: auth, body: body)
        }
    }
    
    fileprivate func requestAuth(to endpoint: Endpoint, with grant: Grant) -> Response<OAuth> {
        return requestAuth(to: endpoint, with: grant).map { token in
            return OAuth(token: token,
                         updated: .now,
                         performer: self)
        }
    }
    
    fileprivate func authenticate(at endpoint: Endpoint, from json: JSON) -> Response<OAuth> {
        do {
            guard let data = json.data else {
                return .errored(with: .cannotPerformRequest)
            }
            let token = try JSONDecoder().decode(OAuth.Token.self, from: data)
            
            let auth = OAuth(token: token,
                             updated: .now,
                             performer: self)
            
            return .successful(with: auth)
        } catch {
            guard let code = json["code"].string else {
                return .errored(with: .cannotPerformRequest)
            }
            return requestAuth(to: endpoint,
                               with: .authorizationCode(code: code))
        }
    }
    
}

// MARK: Refreshing

extension OAuthCabableAPI {
    
    public func refresh(using refreshToken: String?) -> Promise<OAuth.Token, APIError> {
        return requestAuth(to: refreshEndpoint, with: .refreshToken(token: refreshToken))
    }
    
}

// MARK: Public Authentication Methods

extension OAuthCabableAPI {
    
    public func authenticate(callback url: URL) -> Response<OAuth> {
        
        guard let json = url.json else {
            return .errored(with: .cannotPerformRequest)
        }
        let promise = authenticate(at: authEndpoint,
                                   from: json)
        
        promise.onSuccess { token in
            self.store(token: token)
        }
        
        return promise
    }
    
    public func authenticate(authorizationCode code: String) -> Response<OAuth> {
        
        let promise: Response<OAuth> = requestAuth(to: authEndpoint,
                                                   with: .authorizationCode(code: code))
        
        promise.onSuccess { token in
            self.store(token: token)
        }
        
        return promise
    }
    
    public func authenticate(username: String, password: String, scope: String...) -> Response<OAuth> {
        
        let scope = scope.isEmpty ? nil : scope.join(with: " ")
        let grant: Grant = .password(username: username, password: password, scope: scope)
        
        let promise: Response<OAuth> = requestAuth(to: authEndpoint,
                                                   with: grant)
        
        promise.onSuccess { token in
            self.store(token: token)
        }
        
        return promise
    }
    
}

fileprivate extension URL {
    
    var json: JSON? {
        return fragment.map(JSON.init(fragment:)) ?? query.map(JSON.init(fragment:))
    }
    
}
