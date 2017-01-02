//
//  DataRepresentable.swift
//  Pods
//
//  Created by Mathias Quintero on 12/29/16.
//
//

import Foundation

/// Any object that can be fetched throught http as Data
public protocol DataRepresentable {
    init?(data: Data)
}

public extension DataRepresentable {
    
    /// Result of a Single Object
    public typealias Result = Response<Self>
    /// Result of an Array of Objects
    public typealias Results = Response<[Self]>
    
}

/// Any object that can be sent through http as Data
public protocol DataSerializable {
    var data: Data? { get }
}
