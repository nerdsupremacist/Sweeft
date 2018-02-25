//
//  OAuthAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 10/1/17.
//

import Foundation

@available(macOS 10.12, *)
open class OAuthAPI<E: APIEndpoint, Key: StatusKey>: OAuthCabableAPI {
    
    public typealias Endpoint = E
    
    fileprivate lazy var statusFetcher: SimpleStatus<Key, OAuth.Stored?> = { [unowned self] in
        return SimpleStatus(storage: self.storage,
                            key: self.tokenKey,
                            defaultValue: nil)
    }()
    
    public fileprivate(set) lazy var auth: Auth = { [unowned self] in
        var status = self.statusFetcher
        guard let storedToken = status.value else {
            return NoAuth.standard
        }
        
        var oauth = OAuth(stored: storedToken,
                          performer: self)
        
        oauth.onChange { status.value = $0.storable }
        return oauth
    }()
    
    public var isLoggedIn: Bool {
        return self.statusFetcher.value != nil
    }
    
    open var baseHeaders: [String:String] {
        return .empty
    }
    
    open var baseQueries: [String:String] {
        return .empty
    }
    
    open var session: URLSession {
        return .shared
    }
    
    open var dispatcher: Dispatcher {
        return ImmediateDispatcher.default
    }
    
    public let baseURL: String
    
    let storage: Storage
    let tokenKey: Key
    
    public let authEndpoint: Endpoint
    public let refreshEndpoint: Endpoint
    
    public let clientID: String
    public let clientSecret: String
    
    public let useBasicHttp: Bool
    public let useJSON: Bool
    
    public init(baseURL: String,
                storage: Storage = .keychain,
                tokenKey: Key,
                authEndpoint: Endpoint,
                refreshEndpoint: Endpoint? = nil,
                clientID: String,
                clientSecret: String,
                useBasicHttp: Bool = true,
                useJSON: Bool = true) {
        
        self.baseURL = baseURL
        self.storage = storage
        self.tokenKey = tokenKey
        self.authEndpoint = authEndpoint
        self.refreshEndpoint = refreshEndpoint ?? authEndpoint
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.useBasicHttp = useBasicHttp
        self.useJSON = useJSON
    }
    
    public func store(token: OAuth) {
        var token = token
        self.auth = token
        self.statusFetcher.value = token.storable
        token.onChange { self.statusFetcher.value = $0.storable }
    }
    
    open func logout() {
        auth = NoAuth.standard
        statusFetcher.value = nil
    }
    
}
