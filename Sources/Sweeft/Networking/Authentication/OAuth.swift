//
//  OAuth.swift
//  Pods
//
//  Created by Mathias Quintero on 1/4/17.
//
//

import Foundation

@available(macOS 10.12, *)
public final class OAuth: Auth, Observable {
    
    public struct Token: Codable {
        
        enum CodingKeys: String, CodingKey {
            case token = "access_token"
            case tokenType = "token_type"
            case refreshToken = "refresh_token"
            case expiresIn = "expires_in"
        }
        
        let token: String
        let tokenType: String
        let refreshToken: String?
        let expiresIn: Int?
    }
    
    public struct Stored: Codable {
        public let token: Token
        public let updated: Date
    }
    
    public var listeners = [Listener]()
    
    var token: Token
    var updated: Date
    
    weak var performer: RefreshPerformer?
    private var refreshPromise: Response<Token>?
    
    var expirationDate: Date? {
        return token.expiresIn.map { updated.addingTimeInterval(Double($0)) }
    }
    
    public init(token: Token,
                updated: Date,
                performer: RefreshPerformer) {
        
        self.token = token
        self.updated = updated
        self.performer = performer
    }
    
    public convenience init(stored: Stored,
                            performer: RefreshPerformer) {
        
        self.init(token: stored.token,
                  updated: stored.updated,
                  performer: performer)
    }
    
    public func update(with token: Token) {
        self.token = token
        updated = .now
        hasChanged()
    }
    
    public var storable: Stored {
        return Stored(token: token,
                      updated: updated)
    }
    
    public var isExpired: Bool {
        guard let expirationDate = expirationDate else {
            return false
        }
        return expirationDate < .now
    }
    
    public var isRefreshable: Bool {
        return ??token.refreshToken && ??expirationDate
    }
    
    public func refresh() -> Response<Token> {
        guard let performer = performer else {
                
            return .errored(with: .cannotPerformRequest)
        }
        return performer.refresh(using: token.refreshToken)
    }
    
    public func apply(to request: URLRequest) -> Promise<URLRequest, APIError> {
        if isExpired {
            refreshPromise = self.refreshPromise ?? refresh()
            return refreshPromise?.flatMap { (auth: Token) -> Promise<URLRequest, APIError> in
                self.refreshPromise = nil
                self.update(with: auth)
                return self.apply(to: request)
            } ?? .errored(with: .cannotPerformRequest)
        }
        var request = request
        request.addValue("\(token.tokenType) \(token.token)", forHTTPHeaderField: "Authorization")
        return .successful(with: request)
    }
    
}
