//
//  API.swift
//  Pods
//
//  Created by Mathias Quintero on 12/21/16.
//
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

public protocol API {
    associatedtype Endpoint: APIEndpoint
    static var baseURL: String { get }
    var baseHeaders: [String:String] { get }
    var baseQueries: [String:String] { get }
}

public extension API {
    
    var base: URL! {
        return URL(string: Self.baseURL)
    }
    
    var baseHeaders: [String:String] {
        return [:]
    }
    
    var baseQueries: [String:String] {
        return [:]
    }
    
}

public extension API {
    
    public func doDataRequest(with method: HTTPMethod,
                       to endpoint: Endpoint,
                       arguments: [String:CustomStringConvertible] = [:],
                       headers: [String:CustomStringConvertible] = [:],
                       body: Data? = nil) -> Promise<Data, NoError> {
        
        let promise = Promise<Data, NoError>()
        
        let requestString = arguments ==> endpoint.rawValue ** { string, argument in
            return string.replacingOccurrences(of: "{\(argument.key)}", with: argument.value.description)
        }
        
        let url = baseQueries ==> base.appendingPathComponent(requestString) ** { url, query in
            return url.appendingQuery(key: query.key, value: query.value)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data,
                error == nil {
                promise.success(with: data)
            }
        }
        task.resume()
        
        return promise
    }
    
    public func doJSONRequest(with method: HTTPMethod,
                       to endpoint: Endpoint,
                       arguments: [String:CustomStringConvertible] = [:],
                       headers: [String:CustomStringConvertible] = [:],
                       body: JSON? = nil) -> Promise<JSON, NoError> {
        
        let promise = Promise<JSON, NoError>()
        doDataRequest(with: method, to: endpoint, arguments: arguments, headers: headers, body: body?.data)
            .onSuccess { data in
                guard let json = JSON(data: data) else {
                    return
                }
                promise.success(with: json)
            }
            .onError(call: promise.error)
        return promise
    }
    
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod,
                         to endpoint: Endpoint,
                         arguments: [String:CustomStringConvertible] = [:],
                         headers: [String:CustomStringConvertible] = [:],
                         body: JSON? = nil,
                         at path: [String] = []) -> Promise<T, NoError> {
        
        let promise = Promise<T, NoError>()
        doJSONRequest(with: method, to: endpoint, arguments: arguments, headers: headers, body: body)
            .onSuccess { json in
                guard let item: T = json.get(in: path) else {
                    return
                }
                promise.success(with: item)
            }
            .onError(call: promise.error)
        
        return promise
    }
    
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod,
                         to endpoint: Endpoint,
                         arguments: [String:CustomStringConvertible] = [:],
                         headers: [String:CustomStringConvertible] = [:],
                         body: JSON? = nil,
                         at path: String...) -> Promise<T, NoError> {
        
        return doObjectRequest(with: method, to: endpoint, arguments: arguments, headers: headers, body: body, at: path)
    }
    
    
    public func doObjectsRequest<T: Deserializable>(with method: HTTPMethod,
                          to endpoint: Endpoint,
                          arguments: [String:CustomStringConvertible] = [:],
                          headers: [String:CustomStringConvertible] = [:],
                          body: JSON? = nil,
                          at path: [String] = [],
                          with internalPath: [String] = []) -> Promise<[T], NoError> {
        
        
        let promise = Promise<[T], NoError>()
        doJSONRequest(with: method, to: endpoint, arguments: arguments, headers: headers, body: body)
            .onSuccess { json in
                guard let items: [T] = json.getAll(in: path, for: internalPath) else {
                    return
                }
                promise.success(with: items)
            }
            .onError(call: promise.error)
        
        return promise
        
    }
    
}
