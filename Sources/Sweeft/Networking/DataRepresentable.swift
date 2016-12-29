//
//  DataRepresentable.swift
//  Pods
//
//  Created by Mathias Quintero on 12/29/16.
//
//

import Foundation

public protocol DataRepresentable {
    init?(data: Data)
}

public protocol DataSerializable {
    var data: Data? { get }
}
