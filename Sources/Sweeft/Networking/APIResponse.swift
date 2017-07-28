//
//  APIResponse.swift
//  Sweeft
//
//  Created by Mathias Quintero on 7/28/17.
//

import Foundation

public struct APIResponse {
    
    let response: HTTPURLResponse
    public let data: Data?
    
    public var headers: [String : String] {
        return response.allHeaderFields ==> { ($0.key.description, $0.value as? String) } >>> iff >>= id
    }
    
    public var statusCode: Int {
        return response.statusCode
    }
    
    public var location: URL? {
        return headers["Location"] | URL.init(string:)
    }
    
    public var date: Date? {
        return headers["Date"]?.date()
    }
    
}
