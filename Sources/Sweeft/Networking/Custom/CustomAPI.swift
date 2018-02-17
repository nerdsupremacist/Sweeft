//
//  CustomAPI.swift
//  Sweeft
//
//  Created by Mathias Quintero on 7/28/17.
//

import Foundation

public protocol CustomAPI: class, API, URLSessionDataDelegate {
    var configuration: URLSessionConfiguration { get }
}

public extension CustomAPI {
    
    var session: URLSession {
        return URLSession(configuration: self.configuration, delegate: self, delegateQueue: nil)
    }
    
    var configuration: URLSessionConfiguration {
        return .default
    }
    
}
