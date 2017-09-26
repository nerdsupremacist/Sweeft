//
//  APIObjectWithDetail.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/27/17.
//

import Foundation

public typealias APIBasic = Codable & Identifiable

public protocol APIObjectWithDetail: APIObjectValue {
    associatedtype Basic: APIBasic where Basic.Identifier == Identifier
    associatedtype Detail: Codable
    
    var basic: Basic { get }
    var detail: Detail? { get }
    
    init(basic: Basic, detail: Detail?)
}

extension APIObjectWithDetail {
    
    public var id: Identifier {
        return basic.id
    }
    
}

extension APIObjectWithDetail {
    
    init(from decoder: Decoder) throws {
        self.init(basic: try .init(from: decoder),
                  detail: try .init(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try basic.encode(to: encoder)
        if let detail = detail {
            try detail.encode(to: encoder)
        }
    }
    
}
