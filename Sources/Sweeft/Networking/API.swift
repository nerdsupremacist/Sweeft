//
//  API.swift
//  Pods
//
//  Created by Mathias Quintero on 12/21/16.
//
//

import Foundation

/// Response promise from an API
public typealias Response<T> = Promise<T, APIError>

/// API Body
public protocol API {
    /// Endpoint Reference
    associatedtype Endpoint: APIEndpoint
    /// Base URL for the api
    var baseURL: String { get }
    /// Headers that should be included into every single request
    var baseHeaders: [String:String] { get }
    /// Queries that should be included into every single request
    var baseQueries: [String:String] { get }
    /// Will be called before performing a Request for people who like to go deep into the metal
    func willPerform(request: inout URLRequest)
    
    /// Will allow you to prepare more customizable URL Sessions
    func session(for method: HTTPMethod, at endpoint: Endpoint) -> URLSession
}

public extension API {
    
    /// URL Object for the API
    var base: URL! {
        return URL(string: baseURL)
    }
    
    // Cache
    var cache: FileCache {
        return FileCache(directory: String(describing: Self.self))
    }
    
    /// Default is empty
    var baseHeaders: [String:String] {
        return .empty
    }
    
    /// Default is empty
    var baseQueries: [String:String] {
        return .empty
    }
    
    /// Default does nothing
    func willPerform(request: inout URLRequest) {
        // Do Nothing
    }
    
    /// Default is the shared session
    func session(for method: HTTPMethod, at endpoint: Endpoint) -> URLSession {
        return .shared
    }
    
}

public extension API {
    
    /**
     Will form a url for a request
     
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter queries: queries that should be appended to the url
     
     - Returns: resulting URL
     */
    public func url(for endpoint: Endpoint,
                    arguments: [String:CustomStringConvertible] = .empty,
                    queries: [String:CustomStringConvertible] = .empty) -> URL {
        
        let requestString = arguments ==> endpoint.rawValue ** { string, argument in
            return string.replacingOccurrences(of: "{\(argument.key)}", with: argument.value.description)
        }
        
        return (baseQueries + queries >>= { $0.description }) ==> base.appendingPathComponent(requestString) ** { url, query in
            return url.appendingQuery(key: query.key, value: query.value)
        }
    }
    
    /**
     Will form a URLRequest
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter queries: queries that should be appended to the url
     - Parameter body: Data that should be sent in the HTTP Body
     
     - Returns: resulting URLRequest
     */
    public func request(with method: HTTPMethod = .get,
                        for endpoint: Endpoint,
                        arguments: [String:CustomStringConvertible] = .empty,
                        headers: [String:CustomStringConvertible] = .empty,
                        queries: [String:CustomStringConvertible] = .empty,
                        body: Data? = nil) -> URLRequest {
        
        let url = self.url(for: endpoint, arguments: arguments, queries: queries)
        return request(with: method, to: url, headers: headers, body: body)
    }
    
    /**
     Will form a URLRequest
     
     - Parameter method: HTTP Method
     - Parameter url: URL that should be requested
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter body: Data that should be sent in the HTTP Body
     
     - Returns: resulting URLRequest
     */
    public func request(with method: HTTPMethod = .get,
                        to url: URL,
                        headers: [String:CustomStringConvertible] = .empty,
                        body: Data? = nil) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        (baseHeaders + headers >>= { $0.description }) => {
            request.addValue($1, forHTTPHeaderField: $0)
        }
        
        return request
    }
    
    /**
     Will perform a URLRequest
     
     - Parameter request: Request that should be performed
     - Parameter method: HTTP Method
     - Parameter endpoint: Requested endpoint
     - Parameter cacheKey: Key for the Cache
     - Parameter acceptableStatusCodes: Status codes that are considered a success
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of Data
     */
    public func perform(request: URLRequest,
                        method: HTTPMethod,
                        at endpoint: Endpoint,
                        acceptableStatusCodes: [Int] = [200]) -> Response<APIResponse> {
        
        return .new { promise in
            var request = request
            self.willPerform(request: &request)
            let session = self.session(for: method, at: endpoint)
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    if let error = error as? URLError, error.code == .timedOut {
                        promise.error(with: .timeout)
                    } else {
                        promise.error(with: .unknown(error: error))
                    }
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    return promise.error(with: .invalidResponse)
                }
                guard acceptableStatusCodes.contains(response.statusCode) else {
                    return promise.error(with: .invalidStatus(code: response.statusCode, data: data))
                }
                promise.success(with: APIResponse(response: response, data: data))
            }
            task.resume()
        }
    }
    
    public func doRequest(with method: HTTPMethod = .get,
                          to endpoint: Endpoint,
                          arguments: [String:CustomStringConvertible] = .empty,
                          headers: [String:CustomStringConvertible] = .empty,
                          queries: [String:CustomStringConvertible] = .empty,
                          auth: Auth = NoAuth.standard,
                          body: Data? = nil,
                          acceptableStatusCodes: [Int] = [200],
                          completionQueue: DispatchQueue = .main) -> Response<APIResponse> {
        
        let url = self.url(for: endpoint, arguments: arguments, queries: queries)
        let request = self.request(with: method, to: url, headers: headers, body: body)
        
        return auth.apply(to: request).next { request in
            return self.perform(request: request,
                                method: method,
                                at: endpoint,
                                acceptableStatusCodes: acceptableStatusCodes)
        }
    }
    
    /**
     Will do a simple Request
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: Data that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of Data
     */
    public func doDataRequest(with method: HTTPMethod = .get,
                              to endpoint: Endpoint,
                              arguments: [String:CustomStringConvertible] = .empty,
                              headers: [String:CustomStringConvertible] = .empty,
                              queries: [String:CustomStringConvertible] = .empty,
                              auth: Auth = NoAuth.standard,
                              body: Data? = nil,
                              acceptableStatusCodes: [Int] = [200],
                              completionQueue: DispatchQueue = .main,
                              maxCacheTime: CacheTime = .no) -> Data.Result {
        
        let url = self.url(for: endpoint, arguments: arguments, queries: queries)
        let cacheKey = url.relativePath.replacingOccurrences(of: "/", with: "_")
        
        if let cached = cache.get(with: cacheKey, maxTime: maxCacheTime) {
            return .successful(with: cached)
        }
        
        return doRequest(with: method,
                         to: endpoint,
                         arguments: arguments,
                         headers: headers,
                         queries: queries,
                         auth: auth,
                         body: body,
                         acceptableStatusCodes: acceptableStatusCodes,
                         completionQueue: completionQueue).nested { (response, promise) in
                            
                            if let data = response.data {
                                if maxCacheTime != .no {
                                    self.cache.store(data, with: cacheKey)
                                }
                                promise.success(with: data)
                            } else {
                                promise.error(with: .noData)
                            }
        }
    }
    
    /**
     Will do a simple Request of a Data Representable Object
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: Object with the Data that should be sent
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of a Represented Object
     */
    public func doRepresentedRequest<T: DataRepresentable>(with method: HTTPMethod = .get,
                                                           to endpoint: Endpoint,
                                                           arguments: [String:CustomStringConvertible] = .empty,
                                                           headers: [String:CustomStringConvertible] = .empty,
                                                           queries: [String:CustomStringConvertible] = .empty,
                                                           auth: Auth = NoAuth.standard,
                                                           body: DataSerializable? = nil,
                                                           acceptableStatusCodes: [Int] = [200],
                                                           completionQueue: DispatchQueue = .main,
                                                           maxCacheTime: CacheTime = .no) -> Response<T> {
        
        var headers = headers
        headers["Content-Type"] <- body?.contentType
        headers["Accept"] <- T.accept
        
        return doDataRequest(with: method,
                             to: endpoint,
                             arguments: arguments,
                             headers: headers,
                             queries: queries,
                             auth: auth,
                             body: body?.data,
                             acceptableStatusCodes: acceptableStatusCodes,
                             completionQueue: completionQueue,
                             maxCacheTime: maxCacheTime)
            .nested { data, promise in
                guard let underlyingData = T(data: data) else {
                    promise.error(with: .invalidData(data: data))
                    return
                }
                promise.success(with: underlyingData)
        }
    }
    
    /**
     Will do a simple JSON Request
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: JSON that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of JSON Object
     */
    public func doJSONRequest(with method: HTTPMethod = .get,
                              to endpoint: Endpoint,
                              arguments: [String:CustomStringConvertible] = .empty,
                              headers: [String:CustomStringConvertible] = .empty,
                              queries: [String:CustomStringConvertible] = .empty,
                              auth: Auth = NoAuth.standard,
                              body: JSON? = nil,
                              acceptableStatusCodes: [Int] = [200],
                              completionQueue: DispatchQueue = .main,
                              maxCacheTime: CacheTime = .no) -> JSON.Result {
        
        return doRepresentedRequest(with: method,
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
    
    /**
     Will do a simple Request for a Deserializable Object
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter path: path of the object inside the json response
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of the Object
     */
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                                   to endpoint: Endpoint,
                                                   arguments: [String:CustomStringConvertible] = .empty,
                                                   headers: [String:CustomStringConvertible] = .empty,
                                                   queries: [String:CustomStringConvertible] = .empty,
                                                   auth: Auth = NoAuth.standard,
                                                   body: JSON? = nil,
                                                   acceptableStatusCodes: [Int] = [200],
                                                   completionQueue: DispatchQueue = .main,
                                                   at path: [String] = .empty,
                                                   maxCacheTime: CacheTime = .no) -> Response<T> {
        
        return doJSONRequest(with: method,
                             to: endpoint,
                             arguments: arguments,
                             headers: headers,
                             queries: queries,
                             auth: auth,
                             body: body,
                             acceptableStatusCodes: acceptableStatusCodes,
                             completionQueue: completionQueue,
                             maxCacheTime: maxCacheTime).nested { json, promise in
                                
                                guard let item: T = json.get(in: path) else {
                                    promise.error(with: .mappingError(json: json))
                                    return
                                }
                                promise.success(with: item)
        }
    }
    
    /**
     Will do a simple Request for an APIResponseObject
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter path: path of the object inside the json response
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of the Object
     */
    public func doObjectRequest<T: APIResponseObject>(with method: HTTPMethod = .get,
                                                      to endpoint: Endpoint,
                                                      arguments: [String:CustomStringConvertible] = .empty,
                                                      headers: [String:CustomStringConvertible] = .empty,
                                                      queries: [String:CustomStringConvertible] = .empty,
                                                      auth: Auth = NoAuth.standard,
                                                      body: JSON? = nil,
                                                      acceptableStatusCodes: [Int] = [200],
                                                      completionQueue: DispatchQueue = .main,
                                                      at path: [String] = .empty,
                                                      maxCacheTime: CacheTime = .no) -> Response<T> where T.API == Self {
        
        return doJSONRequest(with: method,
                             to: endpoint,
                             arguments: arguments,
                             headers: headers,
                             queries: queries,
                             auth: auth,
                             body: body,
                             acceptableStatusCodes: acceptableStatusCodes,
                             completionQueue: completionQueue,
                             maxCacheTime: maxCacheTime).nested { json, promise in
                                
                                guard let item: T = json.get(in: path, with: self) else {
                                    promise.error(with: .mappingError(json: json))
                                    return
                                }
                                promise.success(with: item)
        }
    }
    
    /**
     Will do a simple Request for an array of Deserializable Objects
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter path: path of the array inside the json object
     - Parameter internalPath: path of the object inside the individual objects inside the array
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of Object Array
     */
    public func doObjectsRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                                    to endpoint: Endpoint,
                                                    arguments: [String:CustomStringConvertible] = .empty,
                                                    headers: [String:CustomStringConvertible] = .empty,
                                                    queries: [String:CustomStringConvertible] = .empty,
                                                    auth: Auth = NoAuth.standard,
                                                    body: JSON? = nil,
                                                    acceptableStatusCodes: [Int] = [200],
                                                    completionQueue: DispatchQueue = .main,
                                                    at path: [String] = .empty,
                                                    with internalPath: [String] = .empty,
                                                    maxCacheTime: CacheTime = .no) -> Response<[T]> {
        
        
        return doJSONRequest(with: method,
                             to: endpoint,
                             arguments: arguments,
                             headers: headers,
                             queries: queries,
                             auth: auth,
                             body: body,
                             acceptableStatusCodes: acceptableStatusCodes,
                             maxCacheTime: maxCacheTime).nested { json, promise in
                                
                                guard let items: [T] = json.getAll(in: path, for: internalPath) else {
                                    promise.error(with: .mappingError(json: json))
                                    return
                                }
                                promise.success(with: items)
        }
    }
    
    /**
     Will do a simple Request for an array of Deserializable Objects
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter path: path of the array inside the json object
     - Parameter internalPath: path of the object inside the individual objects inside the array
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of Object Array
     */
    public func doObjectsRequest<T: APIResponseObject>(with method: HTTPMethod = .get,
                                                    to endpoint: Endpoint,
                                                    arguments: [String:CustomStringConvertible] = .empty,
                                                    headers: [String:CustomStringConvertible] = .empty,
                                                    queries: [String:CustomStringConvertible] = .empty,
                                                    auth: Auth = NoAuth.standard,
                                                    body: JSON? = nil,
                                                    acceptableStatusCodes: [Int] = [200],
                                                    completionQueue: DispatchQueue = .main,
                                                    at path: [String] = .empty,
                                                    with internalPath: [String] = .empty,
                                                    maxCacheTime: CacheTime = .no) -> Response<[T]> where T.API == Self {
        
        
        return doJSONRequest(with: method,
                             to: endpoint,
                             arguments: arguments,
                             headers: headers,
                             queries: queries,
                             auth: auth,
                             body: body,
                             acceptableStatusCodes: acceptableStatusCodes,
                             maxCacheTime: maxCacheTime).nested { json, promise in
                                
                                guard let items: [T] = json.getAll(in: path, for: internalPath, using: self) else {
                                    promise.error(with: .mappingError(json: json))
                                    return
                                }
                                promise.success(with: items)
        }
    }
    
    /**
     Will do a series of requests for objects asynchounously and combine the responses into a single array
     
     - Parameter method: HTTP Method
     - Parameter endpoints: array of endpoints of the API it should be sent to
     - Parameter arguments: Array of arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: Array of JSON Bodies that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter path: path of the array inside the json object
     - Parameter internalPath: path of the object inside the individual objects inside the array
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of Array of objects
     */
    public func doFlatBulkObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                                           to endpoints: [Endpoint],
                                                           arguments: [[String:CustomStringConvertible]] = .empty,
                                                           headers: [String:CustomStringConvertible] = .empty,
                                                           queries: [String:CustomStringConvertible] = .empty,
                                                           auth: Auth = NoAuth.standard,
                                                           bodies: [JSON?] = .empty,
                                                           acceptableStatusCodes: [Int] = [200],
                                                           completionQueue: DispatchQueue = .main,
                                                           at path: [String] = .empty,
                                                           with internalPath: [String] = .empty,
                                                           maxCacheTime: CacheTime = .no) -> Response<[T]> {
        
        return BulkPromise<[T], APIError>(promises: endpoints => { endpoint, index in
            
            let arguments = arguments | index
            let body = bodies | index ?? nil
            return self.doObjectsRequest(with: method,
                                         to: endpoint,
                                         arguments: arguments.?,
                                         headers: headers,
                                         queries: queries,
                                         auth: auth,
                                         body: body,
                                         acceptableStatusCodes: acceptableStatusCodes,
                                         completionQueue: completionQueue,
                                         at: path,
                                         with: internalPath,
                                         maxCacheTime: maxCacheTime)
            
            }, completionQueue: completionQueue).flattened
    }
    
    /**
     Will do a series of requests for objects asynchounously and return an array with all the responses
     
     - Parameter method: HTTP Method
     - Parameter endpoints: array of endpoints of the API it should be sent to
     - Parameter arguments: Array of arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: Array of JSON Bodies that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter path: path of the array inside the json object
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of Array of objects
     */
    public func doBulkObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                                       to endpoints: [Endpoint],
                                                       arguments: [[String:CustomStringConvertible]] = .empty,
                                                       headers: [String:CustomStringConvertible] = .empty,
                                                       queries: [String:CustomStringConvertible] = .empty,
                                                       auth: Auth = NoAuth.standard,
                                                       bodies: [JSON?] = .empty,
                                                       acceptableStatusCodes: [Int] = [200],
                                                       completionQueue: DispatchQueue = .main,
                                                       at path: [String] = .empty,
                                                       maxCacheTime: CacheTime = .no) -> Response<[T]> {
        
        return BulkPromise(promises: endpoints => { endpoint, index in
            
            let arguments = arguments | index
            let body = bodies | index ?? nil
            return self.doObjectRequest(with: method,
                                        to: endpoint,
                                        arguments: arguments.?,
                                        headers: headers,
                                        queries: queries,
                                        auth: auth,
                                        body: body,
                                        acceptableStatusCodes: acceptableStatusCodes,
                                        completionQueue: completionQueue,
                                        at: path,
                                        maxCacheTime: maxCacheTime)
            
            }, completionQueue: completionQueue)
    }
    
    /**
     Will do a series of requests for objects asynchounously and return an array with all the responses
     
     - Parameter method: HTTP Method
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: Array of arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: Array of JSON Bodies that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter path: path of the array inside the json object
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of Array of objects
     */
    public func doBulkObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                                       to endpoint: Endpoint,
                                                       arguments: [[String:CustomStringConvertible]] = .empty,
                                                       headers: [String:CustomStringConvertible] = .empty,
                                                       queries: [String:CustomStringConvertible] = .empty,
                                                       auth: Auth = NoAuth.standard,
                                                       bodies: [JSON?] = .empty,
                                                       acceptableStatusCodes: [Int] = [200],
                                                       completionQueue: DispatchQueue = .main,
                                                       at path: String...,
        maxCacheTime: CacheTime = .no) -> Response<[T]> {
        
        let endpoints = arguments.count.range => returning(endpoint)
        return doBulkObjectRequest(with: method,
                                   to: endpoints,
                                   arguments: arguments,
                                   headers: headers,
                                   queries: queries,
                                   auth: auth,
                                   bodies: bodies,
                                   acceptableStatusCodes: acceptableStatusCodes,
                                   completionQueue: completionQueue,
                                   at: path,
                                   maxCacheTime: maxCacheTime)
    }
    
    /**
     Do a JSON GET Request
     
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: Arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of JSON Object
     */
    public func get(_ endpoint: Endpoint,
                    arguments: [String:CustomStringConvertible] = .empty,
                    headers: [String:CustomStringConvertible] = .empty,
                    queries: [String:CustomStringConvertible] = .empty,
                    auth: Auth = NoAuth.standard,
                    body: JSON? = nil,
                    acceptableStatusCodes: [Int] = [200],
                    completionQueue: DispatchQueue = .main,
                    maxCacheTime: CacheTime = .no) -> JSON.Result {
        
        return doJSONRequest(with: .get,
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
    
    /**
     Do a JSON DELETE Request
     
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: Arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of JSON Object
     */
    public func delete(_ endpoint: Endpoint,
                       arguments: [String:CustomStringConvertible] = .empty,
                       headers: [String:CustomStringConvertible] = .empty,
                       queries: [String:CustomStringConvertible] = .empty,
                       auth: Auth = NoAuth.standard,
                       body: JSON? = nil,
                       acceptableStatusCodes: [Int] = [200],
                       completionQueue: DispatchQueue = .main,
                       maxCacheTime: CacheTime = .no) -> JSON.Result {
        
        return doJSONRequest(with: .delete,
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
    
    /**
     Do a JSON POST Request
     
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: Arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of JSON Object
     */
    public func post(_ body: JSON? = nil,
                     to endpoint: Endpoint,
                     arguments: [String:CustomStringConvertible] = .empty,
                     headers: [String:CustomStringConvertible] = .empty,
                     queries: [String:CustomStringConvertible] = .empty,
                     auth: Auth = NoAuth.standard,
                     acceptableStatusCodes: [Int] = [200],
                     completionQueue: DispatchQueue = .main,
                     maxCacheTime: CacheTime = .no) -> JSON.Result {
        
        return doJSONRequest(with: .post,
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
    
    /**
     Do a JSON PUT Request
     
     - Parameter body: JSON Object that should be sent in the HTTP Body
     - Parameter endpoint: endpoint of the API it should be sent to
     - Parameter arguments: Arguments encoded into the endpoint string
     - Parameter headers: HTTP Headers that should be added to the request
     - Parameter auth: Authentication Manager for the request
     - Parameter acceptableStatusCodes: HTTP Status Codes that mean a succesfull request was done
     - Parameter completionQueue: Queue in which the promise should be run
     - Parameter maxCacheTime: Time the response should be cached
     
     - Returns: Promise of JSON Object
     */
    public func put(_ body: JSON? = nil,
                    at endpoint: Endpoint,
                    arguments: [String:CustomStringConvertible] = .empty,
                    headers: [String:CustomStringConvertible] = .empty,
                    queries: [String:CustomStringConvertible] = .empty,
                    auth: Auth = NoAuth.standard,
                    acceptableStatusCodes: [Int] = [200],
                    completionQueue: DispatchQueue = .main,
                    maxCacheTime: CacheTime = .no) -> JSON.Result {
        
        return doJSONRequest(with: .put,
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

