//
//  APIDescription.swift
//  Pods
//
//  Created by Mathias Quintero on 12/21/16.
//
//

import Foundation

/// Description for
public protocol APIEndpoint {
    /// Raw value string for the key
    var rawValue: String { get }
}
