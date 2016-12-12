//
//  Data.swift
//  Pods
//
//  Created by Mathias Quintero on 12/12/16.
//
//

import Foundation

public extension Data {
    
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
    
}

extension Data: Defaultable {
    
    public static var defaultValue: Data {
        return Data()
    }
    
}
