//
//  DelegatedAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/27/17.
//

import Foundation

@available(macOS 10.12, *)
struct WrappedAPI<Wrapped: API, EndpointType: APIEndpoint>: API {
    typealias Endpoint = EndpointType
    
    let baseURL: String
    let api: Wrapped
    let endpoint: Wrapped.Endpoint
}

@available(macOS 10.12, *)
extension WrappedAPI {
    
    var baseHeaders: [String : String] {
        return api.baseHeaders
    }
    
    var baseQueries: [String : String] {
        return api.baseQueries
    }
    
    var session: URLSession {
        return api.session
    }
    
    var auth: Auth {
        return api.auth
    }
    
    func willPerform(request: inout URLRequest) {
        api.willPerform(request: &request)
    }
    
}

@available(macOS 10.12, *)
extension WrappedAPI {
    
    
    func doAPIObjectRequest<T: APIObjectValue>(with method: HTTPMethod = .get,
                                               endpoint: Endpoint,
                                               arguments: [String:CustomStringConvertible] = .empty,
                                               headers: [String:CustomStringConvertible] = .empty,
                                               queries: [String:CustomStringConvertible] = .empty,
                                               auth: Auth? = nil,
                                               body: Encodable? = nil,
                                               acceptableStatusCodes: [Int] = [200],
                                               completionQueue: DispatchQueue = .global(),
                                               maxCacheTime: CacheTime = .no) -> Response<APIObject<T>> where T.API == Wrapped {
        
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
                                    
            return APIObject(api: self.api, value: value)
        }
    }
    
    func doAPIObjectsRequest<T: APIObjectValue>(with method: HTTPMethod = .get,
                                                endpoint: Endpoint,
                                                arguments: [String:CustomStringConvertible] = .empty,
                                                headers: [String:CustomStringConvertible] = .empty,
                                                queries: [String:CustomStringConvertible] = .empty,
                                                auth: Auth? = nil,
                                                body: Encodable? = nil,
                                                acceptableStatusCodes: [Int] = [200],
                                                completionQueue: DispatchQueue = .global(),
                                                maxCacheTime: CacheTime = .no) -> Response<[APIObject<T>]> where T.API == Wrapped {
        
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
                                  dataDecodingStrategy: T.dataDecodingStrategy).map(completionQueue: completionQueue) { (value: [T]) in
                                    
            return value.map { APIObject(api: self.api, value: $0) }
        }
    }
    
}
