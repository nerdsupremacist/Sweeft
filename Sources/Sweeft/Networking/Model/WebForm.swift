//
//  WebForm.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/22/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Foundation

public struct WebForm {
    
    fileprivate var info: [String : CustomStringConvertible]
    
    public init(with info: [String : CustomStringConvertible] = .empty) {
        self.info = info
    }
    
}

extension WebForm {
    
    public subscript(key: String) -> CustomStringConvertible? {
        get {
            return self.info[key]
        }
        set {
            self.info[key] = key
        }
    }
    
}

extension WebForm: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, CustomStringConvertible?)...) {
        self.init(with: elements ==> iff >>= id)
    }
    
}

extension WebForm: DataSerializable {
    
    public var contentType: String? {
        return "application/x-www-form-urlencoded"
    }
    
    public var data: Data? {
        let mappings = info => { "\($0.key)=\($0.value)" }
        return mappings.joined(separator: "\n").data
    }
    
}
