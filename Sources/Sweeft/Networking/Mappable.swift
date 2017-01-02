//
//  Mappable.swift
//  Pods
//
//  Created by Mathias Quintero on 12/21/16.
//
//

import Foundation

public protocol Deserializable: DataRepresentable {
    init?(from json: JSON)
}

public extension Deserializable {
    
    public init?(data: Data) {
        guard let json = JSON(data: data) else {
            return nil
        }
        self.init(from: json)
    }
    
}

extension Deserializable {
    
    public static func initializer(for path: [String]) -> (JSON) -> Self? {
        return JSON.get ** path
    }
    
    public static func initializer(for path: String...) -> (JSON) -> Self? {
        return initializer(for: path)
    }
    
}

extension Deserializable {
    
    public static func get<T: API>(using api: T,
                           method: HTTPMethod = .get,
                           at endpoint: T.Endpoint,
                           arguments: [String:CustomStringConvertible] = [:],
                           headers: [String:CustomStringConvertible] = [:],
                           auth: Auth = NoAuth.standard,
                           for path: String...) -> Result {
        
        return api.doObjectRequest(with: method, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: nil, at: path)
    }
    
    public static func getAll<T: API>(using api: T,
                              method: HTTPMethod = .get,
                              at endpoint: T.Endpoint,
                              arguments: [String:CustomStringConvertible] = [:],
                              headers: [String:CustomStringConvertible] = [:],
                              auth: Auth = NoAuth.standard,
                              for path: String...,
                              using internalPath: [String] = []) -> Results {
        
        return api.doObjectsRequest(with: method, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: nil, at: path)
    }
    
}

public protocol Serializable {
    var json: JSON { get }
}

extension Serializable {
    
    public func send<T: API>(using api: T,
                            method: HTTPMethod,
                            at endpoint: T.Endpoint,
                            arguments: [String:CustomStringConvertible] = [:],
                            headers: [String:CustomStringConvertible] = [:],
                            auth: Auth = NoAuth.standard) -> JSON.Result {
        
        return api.doJSONRequest(with: method, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: json)
    }
    
    public func put<T: API>(using api: T,
                            at endpoint: T.Endpoint,
                            arguments: [String:CustomStringConvertible] = [:],
                            headers: [String:CustomStringConvertible] = [:],
                            auth: Auth = NoAuth.standard) -> JSON.Result {
        
        return send(using: api, method: .put, at: endpoint, arguments: arguments, headers: headers, auth: auth)
    }
    
    public func post<T: API>(using api: T,
                    at endpoint: T.Endpoint,
                    arguments: [String:CustomStringConvertible] = [:],
                    headers: [String:CustomStringConvertible] = [:],
                    auth: Auth = NoAuth.standard) -> JSON.Result {
        
        return send(using: api, method: .post, at: endpoint, arguments: arguments, headers: headers, auth: auth)
    }
    
}
