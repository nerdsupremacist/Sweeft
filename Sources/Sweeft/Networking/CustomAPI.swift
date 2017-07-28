//
//  CustomAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 7/28/17.
//

import Foundation

extension API where Self: URLSessionDataDelegate {
    
    public func session(for method: HTTPMethod, at endpoint: Endpoint) -> URLSession {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
}

public protocol CustomAPI: API, URLSessionDataDelegate {
    func configuration(for method: HTTPMethod, at endpoint: Endpoint) -> URLSessionConfiguration
}

extension CustomAPI {
    
    public func configuration(for method: HTTPMethod, at endpoint: Endpoint) -> URLSessionConfiguration {
        return .default
    }
    
    public func session(for method: HTTPMethod, at endpoint: Endpoint) -> URLSession {
        let configuration = self.configuration(for: method, at: endpoint)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
}
