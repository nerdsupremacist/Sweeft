//
//  DelegatedAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/27/17.
//

import Foundation

struct WrappedAPI<Wrapped: API, EndpointType: APIEndpoint>: API {
    typealias Endpoint = EndpointType
    
    let baseURL: String
    let api: Wrapped
    let endpoint: Wrapped.Endpoint
}

extension WrappedAPI {
    
    var baseHeaders: [String : String] {
        return api.baseHeaders
    }
    
    var baseQueries: [String : String] {
        return api.baseQueries
    }
    
    var auth: Auth {
        return api.auth
    }
    
    func willPerform(request: inout URLRequest) {
        api.willPerform(request: &request)
    }
    
    func session(for method: HTTPMethod, at endpoint: EndpointType) -> URLSession {
        return api.session(for: method, at: self.endpoint)
    }
    
}

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
