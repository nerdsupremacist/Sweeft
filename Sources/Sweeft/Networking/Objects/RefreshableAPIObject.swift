//
//  RefreshableAPIObject.swift
//  Sweeft
//
//  Created by Mathias Quintero on 10/1/17.
//

import Foundation

public protocol RefreshableAPIObject: APIObjectValue {
    var refreshRequest: Response<Self>? { get }
    func refresh() -> Response<Self>
}
