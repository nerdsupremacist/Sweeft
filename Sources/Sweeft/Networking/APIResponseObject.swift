//
//  APIResponseObject.swift
//  Sweeft
//
//  Created by Mathias Quintero on 9/2/17.
//

import Foundation

public protocol APIResponseObject {
    associatedtype API: Sweeft.API
    init?(api: API, json: JSON)
}

extension APIResponseObject {
    
    public typealias Result = Response<Self>
    public typealias Results = Response<[Self]>
    
    /// Create an Initializer by using a path
    public static func initializer(for path: [String], using api: API) -> (JSON) -> Self? {
        return JSON.get ** (path, api)
    }
    
}
