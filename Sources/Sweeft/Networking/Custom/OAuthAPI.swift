//
//  OAuthAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 10/1/17.
//

import Foundation

open class OAuthAPI<E: APIEndpoint, Key: StatusKey>: API {
    public typealias Endpoint = E
    
    fileprivate var manager: OAuthManager<OAuthEndpoint> {
        return OAuthManager(baseURL: self.baseURL,
                            clientID: self.clientID,
                            secret: self.clientSecret,
                            useBasicHttp: self.useBasicHttp,
                            useJSON: self.useJSON)
    }
    
    fileprivate lazy var statusFetcher: SimpleStatus<Key, OAuth.Token?> = { [unowned self] in
        return SimpleStatus(storage: self.storage,
                            key: self.tokenKey,
                            defaultValue: nil)
    }()
    
    public fileprivate(set) lazy var auth: Auth = { [unowned self] in
        var status = self.statusFetcher
        guard let token = status.value else {
            return NoAuth.standard
        }
        let manager = self.manager
        var oauth = OAuth(token: token,
                          updated: .now,
                          manager: manager,
                          endpoint: OAuthEndpoint(rawValue: self.authEndpoint.rawValue))
        oauth.onChange { status.value = $0.token }
        return oauth
    }()
    
    public let baseURL: String
    
    let storage: Storage
    let tokenKey: Key
    
    let authEndpoint: Endpoint
    
    let clientID: String
    let clientSecret: String
    
    let useBasicHttp: Bool
    let useJSON: Bool
    
    public init(baseURL: String,
                storage: Storage = .keychain,
                tokenKey: Key,
                authEndpoint: Endpoint,
                clientID: String,
                clientSecret: String,
                useBasicHttp: Bool = true,
                useJSON: Bool = true) {
        
        self.baseURL = baseURL
        self.storage = storage
        self.tokenKey = tokenKey
        self.authEndpoint = authEndpoint
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.useBasicHttp = useBasicHttp
        self.useJSON = useJSON
    }
    
}

extension OAuthAPI {
    
    private var endpoint: OAuthEndpoint {
        return .init(rawValue: authEndpoint.rawValue)
    }
    
    public func authenticate(authorizationCode: String) -> Response<OAuth> {
        
        let promise = self.manager.authenticate(at: endpoint,
                                                authorizationCode: authorizationCode)
        
        promise.onSuccess { token in
            var token = token
            self.auth = token
            token.onChange { self.statusFetcher.value = $0.token }
        }
        return promise
    }
    
    public func authenticate(username: String, password: String, scope: String...) -> Response<OAuth> {
        
        let promise = self.manager.authenticate(at: endpoint,
                                                username: username,
                                                password: password,
                                                scope: scope)
        
        promise.onSuccess { token in
            var token = token
            self.auth = token
            token.onChange { self.statusFetcher.value = $0.token }
        }
        return promise
    }
    
    
}
