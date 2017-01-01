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

/// Any object that can be sent through http as Data
public protocol DataSerializable {
    var data: Data? { get }
}
