//
//  APIObject.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/26/17.
//

import Foundation

public protocol APIObjectValue: Codable {
    associatedtype Endpoint: APIEndpoint
    associatedtype API: Sweeft.API
    associatedtype Identifier: CustomStringConvertible
    
    static var endpoint: API.Endpoint { get }
    
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
    static var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get }
    
    var id: Identifier { get }
}

extension APIObjectValue {
    
    public static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
        return .iso8601
    }
    
    public static var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy {
        return .base64
    }
    
    public static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return .iso8601
    }
    
    public static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy {
        return .base64
    }
    
}

extension APIObjectValue {
    
    public func object(using api: API) -> APIObject<Self> {
        return .init(api: api, value: self)
    }
    
}

public struct APIObject<Value: APIObjectValue> {
    let api: Value.API
    var value: Value
}

extension APIObjectValue {
    
    public static func with(id: Identifier,
                            using api: API,
                            arguments: [String:CustomStringConvertible] = .empty,
                            headers: [String:CustomStringConvertible] = .empty,
                            queries: [String:CustomStringConvertible] = .empty,
                            auth: Auth? = nil,
                            body: Encodable? = nil,
                            acceptableStatusCodes: [Int] = [200],
                            completionQueue: DispatchQueue = .global(),
                            maxCacheTime: CacheTime = .no) -> Response<APIObject<Self>> {
        
        return api.doObjectRequest(with: .get,
                                   appending: id.description,
                                   arguments: arguments,
                                   headers: headers,
                                   queries: queries,
                                   auth: auth,
                                   body: body,
                                   acceptableStatusCodes: acceptableStatusCodes,
                                   completionQueue: completionQueue,
                                   maxCacheTime: maxCacheTime)
    }
    
    public static func all(using api: API,
                           arguments: [String:CustomStringConvertible] = .empty,
                           headers: [String:CustomStringConvertible] = .empty,
                           queries: [String:CustomStringConvertible] = .empty,
                           auth: Auth? = nil,
                           body: Encodable? = nil,
                           acceptableStatusCodes: [Int] = [200],
                           completionQueue: DispatchQueue = .global(),
                           maxCacheTime: CacheTime = .no) -> Response<[APIObject<Self>]> {
        
        return api.doObjectsRequest(with: .get,
                                   arguments: arguments,
                                   headers: headers,
                                   queries: queries,
                                   auth: auth,
                                   body: body,
                                   acceptableStatusCodes: acceptableStatusCodes,
                                   completionQueue: completionQueue,
                                   maxCacheTime: maxCacheTime)
    }
    
}

extension APIObject {
    
    public func doRequest<T: APIObjectValue>(with method: HTTPMethod = .get,
                                             to endpoint: Value.Endpoint? = nil,
                                             arguments: [String:CustomStringConvertible] = .empty,
                                             headers: [String:CustomStringConvertible] = .empty,
                                             queries: [String:CustomStringConvertible] = .empty,
                                             auth: Auth? = nil,
                                             body: Encodable? = nil,
                                             acceptableStatusCodes: [Int] = [200],
                                             completionQueue: DispatchQueue = .global(),
                                             maxCacheTime: CacheTime = .no) -> Response<APIObject<T>> {
        
        let pathComponent = endpoint.map { "\(value.id)/\($0.rawValue)" } ?? value.id.description
        
        return api.doObjectRequest(with: method,
                                   endpoint: Value.endpoint,
                                   appending: pathComponent,
                                   arguments: arguments,
                                   headers: headers,
                                   queries: queries,
                                   auth: auth,
                                   body: body,
                                   acceptableStatusCodes: acceptableStatusCodes,
                                   completionQueue: completionQueue,
                                   maxCacheTime: maxCacheTime)
    }
    
    public func doRequest<T: APIObjectValue>(with method: HTTPMethod = .get,
                                             to endpoint: Value.Endpoint? = nil,
                                             arguments: [String:CustomStringConvertible] = .empty,
                                             headers: [String:CustomStringConvertible] = .empty,
                                             queries: [String:CustomStringConvertible] = .empty,
                                             auth: Auth? = nil,
                                             body: Encodable? = nil,
                                             acceptableStatusCodes: [Int] = [200],
                                             completionQueue: DispatchQueue = .global(),
                                             maxCacheTime: CacheTime = .no) -> Response<[APIObject<T>]> {
        
        let pathComponent = endpoint.map { "\(value.id)/\($0.rawValue)" } ?? value.id.description
        
        return api.doObjectsRequest(with: method,
                                    endpoint: Value.endpoint,
                                    appending: pathComponent,
                                    arguments: arguments,
                                    headers: headers,
                                    queries: queries,
                                    auth: auth,
                                    body: body,
                                    acceptableStatusCodes: acceptableStatusCodes,
                                    completionQueue: completionQueue,
                                    maxCacheTime: maxCacheTime)
    }
    
}

extension APIObject {
    
    public func update(using newValue: Value? = nil,
                       headers: [String:CustomStringConvertible] = .empty,
                       queries: [String:CustomStringConvertible] = .empty,
                       auth: Auth? = nil,
                       body: Encodable? = nil,
                       acceptableStatusCodes: [Int] = [200, 204],
                       completionQueue: DispatchQueue = .global(),
                       maxCacheTime: CacheTime = .no) -> Response<APIObject<Value>> {
        
        let newValue = newValue ?? value
        
        return doRequest(with: .put,
                         headers: headers,
                         queries: queries,
                         auth: auth,
                         body: newValue,
                         acceptableStatusCodes: acceptableStatusCodes,
                         completionQueue: completionQueue,
                         maxCacheTime: maxCacheTime)
    }
    
    public func create(headers: [String:CustomStringConvertible] = .empty,
                       queries: [String:CustomStringConvertible] = .empty,
                       auth: Auth? = nil,
                       body: Encodable? = nil,
                       acceptableStatusCodes: [Int] = [200, 204],
                       completionQueue: DispatchQueue = .global(),
                       maxCacheTime: CacheTime = .no) -> Response<APIObject<Value>> {
        
        return api.doObjectRequest(with: .post,
                                   headers: headers,
                                   queries: queries,
                                   auth: auth,
                                   body: value,
                                   acceptableStatusCodes: acceptableStatusCodes,
                                   completionQueue: completionQueue,
                                   maxCacheTime: maxCacheTime)
    }
    
}
