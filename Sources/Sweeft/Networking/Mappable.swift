//
//  Mappable.swift
//  Pods
//
//  Created by Mathias Quintero on 12/21/16.
//
//

import Foundation

public protocol Deserializable {
    init?(from json: JSON)
}

extension Deserializable {
    
    public static func initializer(for path: [String]) -> (JSON) -> Self? {
        return { $0.get(in: path) }
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
                           for path: String...) -> Promise<Self, NoError> {
        
        return api.doObjectRequest(with: method, to: endpoint, arguments: arguments, headers: headers, body: nil, at: path)
    }
    
    public static func getAll<T: API>(using api: T,
                              method: HTTPMethod = .get,
                              at endpoint: T.Endpoint,
                              arguments: [String:CustomStringConvertible] = [:],
                              headers: [String:CustomStringConvertible] = [:],
                              for path: String...,
                              using internalPath: [String] = []) -> Promise<[Self], NoError> {
        
        return api.doObjectsRequest(with: method, to: endpoint, arguments: arguments, headers: headers, body: nil, at: path)
    }
    
}

public protocol Serializable {
    var json: JSON { get }
}
