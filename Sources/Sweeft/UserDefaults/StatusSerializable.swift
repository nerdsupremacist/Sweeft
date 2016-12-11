//
//  DefaultStatusSerializable.swift
//  Pods
//
//  Created by Mathias Quintero on 12/11/16.
//
//

import Foundation

public protocol StatusSerializable {
    var serialized: [String:Any] { get }
    init?(from status: [String:Any])
}
