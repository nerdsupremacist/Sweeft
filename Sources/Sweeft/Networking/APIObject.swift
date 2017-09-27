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
    
    var arguments: [String : CustomStringConvertible] { get }
    
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
    static var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get }
}

extension APIObjectValue {
    
    public var arguments: [String : CustomStringConvertible] {
        return .empty
    }
    
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
    public var value: Value
}

extension APIObjectValue {
    
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
    
    func wrappedAPI(using api: API) -> WrappedAPI<API, Endpoint> {
        let endpoint = Self.endpoint
        let url = api.url(for: endpoint, arguments: arguments).appendingPathComponent(id.description)
        return WrappedAPI(baseURL: url.absoluteString, api: api, endpoint: endpoint)
    }
    
}

extension APIObject {
    
    public func doDecodableRequest<T: Decodable>(with method: HTTPMethod = .get,
                                                 to endpoint: Value.Endpoint,
                                                 arguments: [String:CustomStringConvertible] = .empty,
                                                 headers: [String:CustomStringConvertible] = .empty,
                                                 queries: [String:CustomStringConvertible] = .empty,
                                                 auth: Auth? = nil,
                                                 body: Encodable? = nil,
                                                 acceptableStatusCodes: [Int] = [200],
                                                 completionQueue: DispatchQueue = .global(),
                                                 maxCacheTime: CacheTime = .no) -> Response<T> {
        
        let api = value.wrappedAPI(using: self.api)
        
        return api.doDecodableRequest(with: method,
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
    
    public func doRequest<T: APIObjectValue>(with method: HTTPMethod = .get,
                                             to endpoint: Value.Endpoint,
                                             arguments: [String:CustomStringConvertible] = .empty,
                                             headers: [String:CustomStringConvertible] = .empty,
                                             queries: [String:CustomStringConvertible] = .empty,
                                             auth: Auth? = nil,
                                             body: Encodable? = nil,
                                             acceptableStatusCodes: [Int] = [200],
                                             completionQueue: DispatchQueue = .global(),
                                             maxCacheTime: CacheTime = .no) -> Response<APIObject<T>> where T.API == Value.API {
        
        let api = value.wrappedAPI(using: self.api)
        
        return api.doAPIObjectRequest(with: method,
                                      endpoint: endpoint,
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
                                             to endpoint: Value.Endpoint,
                                             arguments: [String:CustomStringConvertible] = .empty,
                                             headers: [String:CustomStringConvertible] = .empty,
                                             queries: [String:CustomStringConvertible] = .empty,
                                             auth: Auth? = nil,
                                             body: Encodable? = nil,
                                             acceptableStatusCodes: [Int] = [200],
                                             completionQueue: DispatchQueue = .global(),
                                             maxCacheTime: CacheTime = .no) -> Response<[APIObject<T>]> where T.API == Value.API {
        
        let api = value.wrappedAPI(using: self.api)
        
        return api.doAPIObjectsRequest(with: method,
                                       endpoint: endpoint,
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
