//
//  GenerizableError.swift
//  Sweeft
//
//  Created by Mathias Quintero on 8/18/17.
//

import Foundation

public protocol GenerizableError: Error {
    init(error: Error)
}
