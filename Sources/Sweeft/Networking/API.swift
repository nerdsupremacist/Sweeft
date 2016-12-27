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
    
    public func doDataRequest(with method: HTTPMethod = .get,
                       to endpoint: Endpoint,
                       arguments: [String:CustomStringConvertible] = [:],
                       headers: [String:CustomStringConvertible] = [:],
                       body: Data? = nil,
                       acceptableStatusCodes: [Int] = [200],
                       completionQueue: DispatchQueue = .main) -> Promise<Data, APIError> {
        
        let promise = Promise<Data, APIError>(completionQueue: completionQueue)
        
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
            if let error = error {
                promise.error(with: .unknown(error: error))
                return
            }
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            guard acceptableStatusCodes.contains(statusCode) else {
                promise.error(with: .invalidStatus(code: statusCode, data: data))
                return
            }
            if let data = data {
                promise.success(with: data)
            } else if let error = error {
                promise.error(with: .noData)
            }
        }
        task.resume()
        
        return promise
    }
    
    public func doJSONRequest(with method: HTTPMethod = .get,
                       to endpoint: Endpoint,
                       arguments: [String:CustomStringConvertible] = [:],
                       headers: [String:CustomStringConvertible] = [:],
                       body: JSON? = nil,
                       acceptableStatusCodes: [Int] = [200],
                       completionQueue: DispatchQueue = .main) -> Promise<JSON, APIError> {
        
        let promise = Promise<JSON, APIError>(completionQueue: completionQueue)
        doDataRequest(with: method, to: endpoint, arguments: arguments,
                      headers: headers, body: body?.data, acceptableStatusCodes: acceptableStatusCodes)
            .onSuccess { data in
                guard let json = JSON(data: data) else {
                    promise.error(with: .invalidJSON)
                    return
                }
                promise.success(with: json)
            }
            .onError(call: promise.error)
        return promise
    }
    
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                         to endpoint: Endpoint,
                         arguments: [String:CustomStringConvertible] = [:],
                         headers: [String:CustomStringConvertible] = [:],
                         body: JSON? = nil,
                         acceptableStatusCodes: [Int] = [200],
                         completionQueue: DispatchQueue = .main,
                         at path: [String] = []) -> Promise<T, APIError> {
        
        let promise = Promise<T, APIError>(completionQueue: completionQueue)
        doJSONRequest(with: method, to: endpoint, arguments: arguments,
                      headers: headers, body: body, acceptableStatusCodes: acceptableStatusCodes)
            .onSuccess { json in
                guard let item: T = json.get(in: path) else {
                    promise.error(with: .mappingError(json: json))
                    return
                }
                promise.success(with: item)
            }
            .onError(call: promise.error)
        
        return promise
    }
    
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                         to endpoint: Endpoint,
                         arguments: [String:CustomStringConvertible] = [:],
                         headers: [String:CustomStringConvertible] = [:],
                         body: JSON? = nil,
                         acceptableStatusCodes: [Int] = [200],
                         completionQueue: DispatchQueue = .main,
                         at path: String...) -> Promise<T, APIError> {
        
        return doObjectRequest(with: method, to: endpoint, arguments: arguments,
                               headers: headers, body: body, acceptableStatusCodes: acceptableStatusCodes, at: path)
    }
    
    
    public func doObjectsRequest<T: Deserializable>(with method: HTTPMethod = .get,
                          to endpoint: Endpoint,
                          arguments: [String:CustomStringConvertible] = [:],
                          headers: [String:CustomStringConvertible] = [:],
                          body: JSON? = nil,
                          acceptableStatusCodes: [Int] = [200],
                          completionQueue: DispatchQueue = .main,
                          at path: [String] = [],
                          with internalPath: [String] = []) -> Promise<[T], APIError> {
        
        
        let promise = Promise<[T], APIError>(completionQueue: completionQueue)
        doJSONRequest(with: method, to: endpoint, arguments: arguments,
                      headers: headers, body: body, acceptableStatusCodes: acceptableStatusCodes)
            .onSuccess { json in
                guard let items: [T] = json.getAll(in: path, for: internalPath) else {
                    promise.error(with: .mappingError(json: json))
                    return
                }
                promise.success(with: items)
            }
            .onError(call: promise.error)
        
        return promise
        
    }
    
}
