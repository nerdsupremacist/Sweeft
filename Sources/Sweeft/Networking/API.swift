//
//  API.swift
//  Pods
//
//  Created by Mathias Quintero on 12/21/16.
//
//

import Foundation

public typealias Response<T> = Promise<T, APIError>

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

public protocol API {
    associatedtype Endpoint: APIEndpoint
    var baseURL: String { get }
    var baseHeaders: [String:String] { get }
    var baseQueries: [String:String] { get }
}

public extension API {
    
    var base: URL! {
        return URL(string: baseURL)
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
                       auth: Auth = NoAuth.standard,
                       body: Data? = nil,
                       acceptableStatusCodes: [Int] = [200],
                       completionQueue: DispatchQueue = .main) -> Data.Result {
        
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
        
        (baseHeaders + headers >>= { ($0, $1.description) }) => {
            request.addValue($1, forHTTPHeaderField: $0)
        }
        
        auth.apply(to: &request)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                if let error = error as? URLError, error.code == .timedOut {
                    promise.error(with: .timeout)
                } else {
                    promise.error(with: .unknown(error: error))
                }
                return
            }
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            guard acceptableStatusCodes.contains(statusCode) else {
                promise.error(with: .invalidStatus(code: statusCode, data: data))
                return
            }
            if let data = data {
                promise.success(with: data)
            } else {
                promise.error(with: .noData)
            }
        }
        task.resume()
        
        return promise
    }
    
    public func doRepresentedRequest<T: DataRepresentable>(with method: HTTPMethod = .get,
                                     to endpoint: Endpoint,
                                     arguments: [String:CustomStringConvertible] = [:],
                                     headers: [String:CustomStringConvertible] = [:],
                                     auth: Auth = NoAuth.standard,
                                     body: DataSerializable? = nil,
                                     acceptableStatusCodes: [Int] = [200],
                                     completionQueue: DispatchQueue = .main) -> Response<T> {
        
        
        return doDataRequest(with: method, to: endpoint, arguments: arguments,
                      headers: headers, auth: auth, body: body?.data, acceptableStatusCodes: acceptableStatusCodes)
                .nested { data, promise in
                    guard let underlyingData = T(data: data) else {
                        promise.error(with: .invalidData(data: data))
                        return
                    }
                    promise.success(with: underlyingData)
                }
    }
    
    public func doJSONRequest(with method: HTTPMethod = .get,
                       to endpoint: Endpoint,
                       arguments: [String:CustomStringConvertible] = [:],
                       headers: [String:CustomStringConvertible] = [:],
                       auth: Auth = NoAuth.standard,
                       body: JSON? = nil,
                       acceptableStatusCodes: [Int] = [200],
                       completionQueue: DispatchQueue = .main) -> JSON.Result {
        
        return doRepresentedRequest(with: method, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes, completionQueue: completionQueue)
    }
    
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                         to endpoint: Endpoint,
                         arguments: [String:CustomStringConvertible] = [:],
                         headers: [String:CustomStringConvertible] = [:],
                         auth: Auth = NoAuth.standard,
                         body: JSON? = nil,
                         acceptableStatusCodes: [Int] = [200],
                         completionQueue: DispatchQueue = .main,
                         at path: [String] = []) -> Response<T> {
        
        return doJSONRequest(with: method, to: endpoint, arguments: arguments,
                      headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes)
            .nested { json, promise in
                guard let item: T = json.get(in: path) else {
                    promise.error(with: .mappingError(json: json))
                    return
                }
                promise.success(with: item)
            }
    }
    
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                         to endpoint: Endpoint,
                         arguments: [String:CustomStringConvertible] = [:],
                         headers: [String:CustomStringConvertible] = [:],
                         auth: Auth = NoAuth.standard,
                         body: JSON? = nil,
                         acceptableStatusCodes: [Int] = [200],
                         completionQueue: DispatchQueue = .main,
                         at path: String...) -> Response<T> {
        
        return doObjectRequest(with: method, to: endpoint, arguments: arguments,
                               headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes, at: path)
    }
    
    
    public func doObjectsRequest<T: Deserializable>(with method: HTTPMethod = .get,
                          to endpoint: Endpoint,
                          arguments: [String:CustomStringConvertible] = [:],
                          headers: [String:CustomStringConvertible] = [:],
                          auth: Auth = NoAuth.standard,
                          body: JSON? = nil,
                          acceptableStatusCodes: [Int] = [200],
                          completionQueue: DispatchQueue = .main,
                          at path: [String] = [],
                          with internalPath: [String] = []) -> Response<[T]> {
        
        
        return doJSONRequest(with: method, to: endpoint, arguments: arguments,
                      headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes)
            .nested { json, promise in
                guard let items: [T] = json.getAll(in: path, for: internalPath) else {
                    promise.error(with: .mappingError(json: json))
                    return
                }
                promise.success(with: items)
            }
    }
    
    public func doFlatBulkObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                    to endpoints: [Endpoint],
                                    arguments: [[String:CustomStringConvertible]] = [],
                                    headers: [String:CustomStringConvertible] = [:],
                                    auth: Auth = NoAuth.standard,
                                    bodies: [JSON?] = [],
                                    acceptableStatusCodes: [Int] = [200],
                                    completionQueue: DispatchQueue = .main,
                                    at path: [String] = [],
                                    with internalPath: [String] = []) -> Response<[T]> {
        
        return BulkPromise<[T], APIError>(promises: endpoints => { endpoint, index in
            let arguments = arguments | index
            let body = bodies | index ?? nil
            return self.doObjectsRequest(with: method, to: endpoint, arguments: arguments.?,
                                         headers: headers, auth: auth, body: body,
                                         acceptableStatusCodes: acceptableStatusCodes,
                                         completionQueue: completionQueue, at: path, with: internalPath)
            
        }, completionQueue: completionQueue).flattened
    }
    
    public func doBulkObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                    to endpoints: [Endpoint],
                                    arguments: [[String:CustomStringConvertible]] = [],
                                    headers: [String:CustomStringConvertible] = [:],
                                    auth: Auth = NoAuth.standard,
                                    bodies: [JSON?] = [],
                                    acceptableStatusCodes: [Int] = [200],
                                    completionQueue: DispatchQueue = .main,
                                    at path: [String] = []) -> Response<[T]> {
        
        return BulkPromise(promises: endpoints => { endpoint, index in
            let arguments = arguments | index
            let body = bodies | index ?? nil
            return self.doObjectRequest(with: method, to: endpoint, arguments: arguments.?,
                                        headers: headers, auth: auth, body: body,
                                        acceptableStatusCodes: acceptableStatusCodes,
                                        completionQueue: completionQueue, at: path)
            
        }, completionQueue: completionQueue)
    }

    public func doBulkObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                              to endpoint: Endpoint,
                              arguments: [[String:CustomStringConvertible]] = [],
                              headers: [String:CustomStringConvertible] = [:],
                              auth: Auth = NoAuth.standard,
                              bodies: [JSON?] = [],
                              acceptableStatusCodes: [Int] = [200],
                              completionQueue: DispatchQueue = .main,
                              at path: String...) -> Response<[T]> {
        
        let endpoints = arguments.count.range => **{ endpoint }
        return doBulkObjectRequest(with: method, to: endpoints, arguments: arguments, headers: headers, auth: auth, bodies: bodies, acceptableStatusCodes: acceptableStatusCodes, completionQueue: completionQueue, at: path)
    }
    
    public func get(_ endpoint: Endpoint,
                    arguments: [String:CustomStringConvertible] = [:],
                    headers: [String:CustomStringConvertible] = [:],
                    auth: Auth = NoAuth.standard,
                    body: JSON? = nil,
                    acceptableStatusCodes: [Int] = [200],
                    completionQueue: DispatchQueue = .main) -> JSON.Result {
        
        return doJSONRequest(with: .get, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes, completionQueue: completionQueue)
    }
    
    public func delete(_ endpoint: Endpoint,
                    arguments: [String:CustomStringConvertible] = [:],
                    headers: [String:CustomStringConvertible] = [:],
                    auth: Auth = NoAuth.standard,
                    body: JSON? = nil,
                    acceptableStatusCodes: [Int] = [200],
                    completionQueue: DispatchQueue = .main) -> JSON.Result {
        
        return doJSONRequest(with: .delete, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes, completionQueue: completionQueue)
    }
    
    public func post(_ body: JSON? = nil,
                     to endpoint: Endpoint,
                     arguments: [String:CustomStringConvertible] = [:],
                     headers: [String:CustomStringConvertible] = [:],
                     auth: Auth = NoAuth.standard,
                     acceptableStatusCodes: [Int] = [200],
                     completionQueue: DispatchQueue = .main) -> JSON.Result {
        
        return doJSONRequest(with: .post, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes, completionQueue: completionQueue)
    }
    
    public func put(_ body: JSON? = nil,
                     at endpoint: Endpoint,
                     arguments: [String:CustomStringConvertible] = [:],
                     headers: [String:CustomStringConvertible] = [:],
                     auth: Auth = NoAuth.standard,
                     acceptableStatusCodes: [Int] = [200],
                     completionQueue: DispatchQueue = .main) -> JSON.Result {
        
        return doJSONRequest(with: .put, to: endpoint, arguments: arguments, headers: headers, auth: auth, body: body, acceptableStatusCodes: acceptableStatusCodes, completionQueue: completionQueue)
    }
    
}
