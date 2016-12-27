//
//  APIError.swift
//  Pods
//
//  Created by Mathias Quintero on 12/26/16.
//
//

import Foundation

public enum APIError: Error {
    case noData
    case timeout
    case invalidStatus(code: Int, data: Data?)
    case invalidJSON
    case mappingError(json: JSON)
    case unknown(error: Error)
}
