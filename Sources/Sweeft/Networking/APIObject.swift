//
//  APIObject.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/26/17.
//

import Foundation

public protocol Identifiable {
    associatedtype Identifier: CustomStringConvertible
    var id: Identifier { get }
}

public protocol APIObjectValue: Codable, Identifiable {
    associatedtype Endpoint: APIEndpoint
    associatedtype API: Sweeft.API
    
    static var endpoint: API.Endpoint { get }
    
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
    static var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get }
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
        
        return api.doAPIObjectRequest(with: .get,
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
        
        return api.doAPIObjectsRequest(with: .get,
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

extension APIObjectValue {
    
    public static func doDecodableRequest<T: Decodable>(using api: API,
                                                        id: Identifier,
                                                        with method: HTTPMethod = .get,
                                                        to endpoint: Endpoint?,
                                                        arguments: [String:CustomStringConvertible] = .empty,
                                                        headers: [String:CustomStringConvertible] = .empty,
                                                        queries: [String:CustomStringConvertible] = .empty,
                                                        auth: Auth? = nil,
                                                        body: Encodable? = nil,
                                                        acceptableStatusCodes: [Int] = [200],
                                                        completionQueue: DispatchQueue = .global(),
                                                        maxCacheTime: CacheTime = .no) -> Response<T> {
        
        let pathComponent = endpoint.map { "\(id)/\($0.rawValue)" } ?? id.description
        
        return api.doDecodableRequest(with: method,
                                      to: Self.endpoint,
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
    
    public static func doRequest<T: APIObjectValue>(using api: API,
                                                    id: Identifier,
                                                    with method: HTTPMethod = .get,
                                                    to endpoint: Endpoint?,
                                                    arguments: [String:CustomStringConvertible] = .empty,
                                                    headers: [String:CustomStringConvertible] = .empty,
                                                    queries: [String:CustomStringConvertible] = .empty,
                                                    auth: Auth? = nil,
                                                    body: Encodable? = nil,
                                                    acceptableStatusCodes: [Int] = [200],
                                                    completionQueue: DispatchQueue = .global(),
                                                    maxCacheTime: CacheTime = .no) -> Response<APIObject<T>> where T.API == API {
        
        let pathComponent = endpoint.map { "\(id)/\($0.rawValue)" } ?? id.description
        
        return api.doAPIObjectRequest(with: method,
                                      endpoint: Self.endpoint,
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
    
    public static func doRequest<T: APIObjectValue>(using api: API,
                                                    id: Identifier,
                                                    with method: HTTPMethod = .get,
                                                    to endpoint: Endpoint?,
                                                    arguments: [String:CustomStringConvertible] = .empty,
                                                    headers: [String:CustomStringConvertible] = .empty,
                                                    queries: [String:CustomStringConvertible] = .empty,
                                                    auth: Auth? = nil,
                                                    body: Encodable? = nil,
                                                    acceptableStatusCodes: [Int] = [200],
                                                    completionQueue: DispatchQueue = .global(),
                                                    maxCacheTime: CacheTime = .no) -> Response<[APIObject<T>]> where T.API == API {
        
        let pathComponent = endpoint.map { "\(id)/\($0.rawValue)" } ?? id.description
        
        return api.doAPIObjectsRequest(with: method,
                                       endpoint: Self.endpoint,
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
    
    public func doDecodableRequest<T: Decodable>(with method: HTTPMethod = .get,
                                                 to endpoint: Value.Endpoint?,
                                                 arguments: [String:CustomStringConvertible] = .empty,
                                                 headers: [String:CustomStringConvertible] = .empty,
                                                 queries: [String:CustomStringConvertible] = .empty,
                                                 auth: Auth? = nil,
                                                 body: Encodable? = nil,
                                                 acceptableStatusCodes: [Int] = [200],
                                                 completionQueue: DispatchQueue = .global(),
                                                 maxCacheTime: CacheTime = .no) -> Response<T> {
        
        return Value.doDecodableRequest(using: api,
                                        id: value.id,
                                        with: method,
                                        to: nil,
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
                                             to endpoint: Value.Endpoint?,
                                             arguments: [String:CustomStringConvertible] = .empty,
                                             headers: [String:CustomStringConvertible] = .empty,
                                             queries: [String:CustomStringConvertible] = .empty,
                                             auth: Auth? = nil,
                                             body: Encodable? = nil,
                                             acceptableStatusCodes: [Int] = [200],
                                             completionQueue: DispatchQueue = .global(),
                                             maxCacheTime: CacheTime = .no) -> Response<APIObject<T>> where T.API == Value.API {
        
        return Value.doRequest(using: api,
                               id: value.id,
                               with: method,
                               to: nil,
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
                                             to endpoint: Value.Endpoint?,
                                             arguments: [String:CustomStringConvertible] = .empty,
                                             headers: [String:CustomStringConvertible] = .empty,
                                             queries: [String:CustomStringConvertible] = .empty,
                                             auth: Auth? = nil,
                                             body: Encodable? = nil,
                                             acceptableStatusCodes: [Int] = [200],
                                             completionQueue: DispatchQueue = .global(),
                                             maxCacheTime: CacheTime = .no) -> Response<[APIObject<T>]> where T.API == Value.API {
        
        return Value.doRequest(using: api,
                               id: value.id,
                               with: method,
                               to: endpoint,
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
                         to: nil,
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
        
        return api.doAPIObjectRequest(with: .post,
                                      headers: headers,
                                      queries: queries,
                                      auth: auth,
                                      body: value,
                                      acceptableStatusCodes: acceptableStatusCodes,
                                      completionQueue: completionQueue,
                                      maxCacheTime: maxCacheTime)
    }
    
}
