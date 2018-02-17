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
    /// URLSession used to run request
    var session: URLSession { get }
    /// Holds the authentication related to the entire API
    var auth: Auth { get }
    /// Cache where the requests will be stored
    var cache: FileCache { get }
    /// Dispatcher responsible for running the request
    var dispatcher: Dispatcher { get }
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
    
    var session: URLSession {
        return .shared
    }
    
    var auth: Auth {
        return NoAuth.standard
    }
    
    var dispatcher: Dispatcher {
        return ImmediateDispatcher.default
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
        
        let base = self.base.appendingPathComponent(requestString)
        
        return (baseQueries + queries >>= { $0.description }) ==> base ** { url, query in
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
                        acceptableStatusCodes: [Int] = [200],
                        completionQueue: DispatchQueue = .global()) -> Response<APIResponse> {
        
        return .new(completionQueue: completionQueue,
                    dispatcher: dispatcher) { setter in
                        
            var request = request
            self.willPerform(request: &request)
            let session = self.session(for: method, at: endpoint)
            let task = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    if let error = error as? URLError, error.code == .timedOut {
                        setter.error(with: .timeout)
                    } else {
                        setter.error(with: .unknown(error: error))
                    }
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    return setter.error(with: .invalidResponse)
                }
                guard acceptableStatusCodes.contains(response.statusCode) else {
                    return setter.error(with: .invalidStatus(code: response.statusCode, data: data))
                }
                setter.success(with: APIResponse(response: response, data: data))
            }
            setter.onCancel { [weak task] in
                task?.cancel()
            }
            task.resume()
        }
    }
    
    public func doRequest(with method: HTTPMethod = .get,
                          to endpoint: Endpoint,
                          arguments: [String:CustomStringConvertible] = .empty,
                          headers: [String:CustomStringConvertible] = .empty,
                          queries: [String:CustomStringConvertible] = .empty,
                          auth: Auth? = nil,
                          body: Data? = nil,
                          acceptableStatusCodes: [Int] = [200],
                          completionQueue: DispatchQueue = .global()) -> Response<APIResponse> {
        
        let url = self.url(for: endpoint, arguments: arguments, queries: queries)
        let request = self.request(with: method, to: url, headers: headers, body: body)
        
        let auth = auth ?? self.auth
        
        return auth.apply(to: request).flatMap(completionQueue: completionQueue) { request in
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
                              auth: Auth? = nil,
                              body: Data? = nil,
                              acceptableStatusCodes: [Int] = [200],
                              completionQueue: DispatchQueue = .global(),
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
                         acceptableStatusCodes: acceptableStatusCodes).flatMap(completionQueue: completionQueue) { response in
                            
                            if let data = response.data {
                                if maxCacheTime != .no {
                                    self.cache.store(data, with: cacheKey)
                                }
                                return .successful(with: data)
                            } else {
                                return .errored(with: .noData)
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
                                                           auth: Auth? = nil,
                                                           body: DataSerializable? = nil,
                                                           acceptableStatusCodes: [Int] = [200],
                                                           completionQueue: DispatchQueue = .global(),
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
                             maxCacheTime: maxCacheTime).flatMap(completionQueue: completionQueue) { data in
                                
                guard let underlyingData = T(data: data) else {
                    return .errored(with: .invalidData(data: data))
                }
                return .successful(with: underlyingData)
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
                              arguments: [String : CustomStringConvertible] = .empty,
                              headers: [String : CustomStringConvertible] = .empty,
                              queries: [String : CustomStringConvertible] = .empty,
                              auth: Auth? = nil,
                              body: JSON? = nil,
                              acceptableStatusCodes: [Int] = [200],
                              completionQueue: DispatchQueue = .global(),
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
    @available(*, deprecated, message:  "Deserializable is deprecated and will soon no longer be supported")
    public func doObjectRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                                   to endpoint: Endpoint,
                                                   arguments: [String:CustomStringConvertible] = .empty,
                                                   headers: [String:CustomStringConvertible] = .empty,
                                                   queries: [String:CustomStringConvertible] = .empty,
                                                   auth: Auth? = nil,
                                                   body: JSON? = nil,
                                                   acceptableStatusCodes: [Int] = [200],
                                                   completionQueue: DispatchQueue = .global(),
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
                             maxCacheTime: maxCacheTime).flatMap(completionQueue: completionQueue) { json in
                                
                                guard let item: T = json.get(in: path) else {
                                    return .errored(with: .mappingError(json: json))
                                }
                                return .successful(with: item)
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
    
    @available(*, deprecated, message: "Deserializable is deprecated and will soon no longer be supported")
    public func doObjectsRequest<T: Deserializable>(with method: HTTPMethod = .get,
                                                    to endpoint: Endpoint,
                                                    arguments: [String:CustomStringConvertible] = .empty,
                                                    headers: [String:CustomStringConvertible] = .empty,
                                                    queries: [String:CustomStringConvertible] = .empty,
                                                    auth: Auth? = nil,
                                                    body: JSON? = nil,
                                                    acceptableStatusCodes: [Int] = [200],
                                                    completionQueue: DispatchQueue = .global(),
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
                             maxCacheTime: maxCacheTime).flatMap(completionQueue: completionQueue) { json in
                                
                                guard let items: [T] = json.getAll(in: path, for: internalPath) else {
                                    return .errored(with: .mappingError(json: json))
                                }
                                return .successful(with: items)
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
                                                           auth: Auth? = nil,
                                                           bodies: [JSON?] = .empty,
                                                           acceptableStatusCodes: [Int] = [200],
                                                           completionQueue: DispatchQueue = .global(),
                                                           at path: [String] = .empty,
                                                           with internalPath: [String] = .empty,
                                                           maxCacheTime: CacheTime = .no) -> Response<[T]> {
        
        return BulkPromise<[T], APIError>(promises: endpoints.withIndex => { endpoint, index in
            
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
                                         at: path,
                                         with: internalPath,
                                         maxCacheTime: maxCacheTime)
            
            }, completionQueue: completionQueue).flattened
    }
    
    @available(macOS 10.12, *)
    func doDecodableRequest<T: Decodable>(with method: HTTPMethod = .get,
                                          to endpoint: Endpoint,
                                          arguments: [String:CustomStringConvertible] = .empty,
                                          headers: [String:CustomStringConvertible] = .empty,
                                          queries: [String:CustomStringConvertible] = .empty,
                                          auth: Auth? = nil,
                                          body: Encodable? = nil,
                                          acceptableStatusCodes: [Int] = [200],
                                          completionQueue: DispatchQueue = .global(),
                                          maxCacheTime: CacheTime = .no,
                                          dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601,
                                          dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64,
                                          dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601,
                                          dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64) -> Response<T> {
        
        let body = body.flatMap {
            $0.encoded(dateEncodingStrategy: dateEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy)
        }
        
        return doDataRequest(with: method,
                             to: endpoint,
                             arguments: arguments,
                             headers: headers,
                             queries: queries,
                             auth: auth,
                             body: body,
                             acceptableStatusCodes: acceptableStatusCodes,
                             maxCacheTime: maxCacheTime).flatMap(completionQueue: completionQueue) { data in
                                
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = dateDecodingStrategy
                                decoder.dataDecodingStrategy = dataDecodingStrategy
                                do {
                                    return .successful(with: try decoder.decode(T.self, from: data))
                                } catch let error as DecodingError {
                                    return .errored(with: .decodingError(error: error))
                                } catch {
                                    return .errored(with: .unknown(error: error))
                                }
        }
    }
    
    @available(macOS 10.12, *)
    func doAPIObjectRequest<T: APIObjectValue>(with method: HTTPMethod = .get,
                                            endpoint: Endpoint = T.endpoint,
                                            arguments: [String:CustomStringConvertible] = .empty,
                                            headers: [String:CustomStringConvertible] = .empty,
                                            queries: [String:CustomStringConvertible] = .empty,
                                            auth: Auth? = nil,
                                            body: Encodable? = nil,
                                            acceptableStatusCodes: [Int] = [200],
                                            completionQueue: DispatchQueue = .global(),
                                            maxCacheTime: CacheTime = .no) -> Response<APIObject<T>> where T.API == Self {
        
        return doDecodableRequest(with: method,
                                  to: endpoint,
                                  arguments: arguments,
                                  headers: headers,
                                  queries: queries,
                                  auth: auth,
                                  body: body,
                                  acceptableStatusCodes: acceptableStatusCodes,
                                  maxCacheTime: maxCacheTime,
                                  dateEncodingStrategy: T.dateEncodingStrategy,
                                  dataEncodingStrategy: T.dataEncodingStrategy,
                                  dateDecodingStrategy: T.dateDecodingStrategy,
                                  dataDecodingStrategy: T.dataDecodingStrategy).map(completionQueue: completionQueue) { value in
                                    
            return APIObject(api: self, value: value)
        }
    }
    
    @available(macOS 10.12, *)
    func doAPIObjectsRequest<T: APIObjectValue>(with method: HTTPMethod = .get,
                                                endpoint: Endpoint = T.endpoint,
                                                arguments: [String:CustomStringConvertible] = .empty,
                                                headers: [String:CustomStringConvertible] = .empty,
                                                queries: [String:CustomStringConvertible] = .empty,
                                                auth: Auth? = nil,
                                                body: Encodable? = nil,
                                                acceptableStatusCodes: [Int] = [200],
                                                completionQueue: DispatchQueue = .global(),
                                                maxCacheTime: CacheTime = .no) -> Response<[APIObject<T>]> where T.API == Self {
        
        return doDecodableRequest(with: method,
                                  to: endpoint,
                                  headers: headers,
                                  queries: queries,
                                  auth: auth,
                                  body: body,
                                  acceptableStatusCodes: acceptableStatusCodes,
                                  maxCacheTime: maxCacheTime,
                                  dateEncodingStrategy: T.dateEncodingStrategy,
                                  dataEncodingStrategy: T.dataEncodingStrategy,
                                  dateDecodingStrategy: T.dateDecodingStrategy,
                                  dataDecodingStrategy: T.dataDecodingStrategy).map(completionQueue: completionQueue) { (value: [T]) in
                                    
            return value.map { APIObject(api: self, value: $0) }
        }
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
                                                       auth: Auth? = nil,
                                                       bodies: [JSON?] = .empty,
                                                       acceptableStatusCodes: [Int] = [200],
                                                       completionQueue: DispatchQueue = .global(),
                                                       at path: [String] = .empty,
                                                       maxCacheTime: CacheTime = .no) -> Response<[T]> {
        
        return BulkPromise(promises: endpoints.withIndex => { endpoint, index in
            
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
                                                       auth: Auth? = nil,
                                                       bodies: [JSON?] = .empty,
                                                       acceptableStatusCodes: [Int] = [200],
                                                       completionQueue: DispatchQueue = .global(),
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
    
}

@available(macOS 10.12, *)
extension Encodable {
    
    fileprivate func encoded(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601,
                 dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64) -> Data? {
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.dataEncodingStrategy = dataEncodingStrategy
        return try? encoder.encode(self)
    }
    
}

