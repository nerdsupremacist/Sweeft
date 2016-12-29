//
//  URL.swift
//  Pods
//
//  Created by Mathias Quintero on 12/26/16.
//
//

import Foundation

public extension URL {
    
    func appendingQuery(key: String, value: String) -> URL {
        let string = self.absoluteString + (??query ? "&" : "?") + "\(key)=\(value)"
        return URL(string: string)!
    }
    
}
