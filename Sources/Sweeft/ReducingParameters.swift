
//
//  ReducingParameters.swift
//  Pods
//
//  Created by Mathias Quintero on 12/7/16.
//
//

import Foundation

public protocol ReducingParameters {
    
    associatedtype Input
    associatedtype Result
    associatedtype NextPartialResultHandler
    
    var nextPartialResult: NextPartialResultHandler { get }
    var initialResult: Result { get }
    
    init(initialResult: Result, nextPartialResult: NextPartialResultHandler)
}

public struct RegularReducingParameters<I, R>: ReducingParameters {
    
    public typealias Input = I
    public typealias Result = R
    public typealias NextPartialResultHandler = (Result, Input) -> (Result)
    
    public let initialResult: Result
    public let nextPartialResult: NextPartialResultHandler
 
    public init(initialResult: Result, nextPartialResult: @escaping NextPartialResultHandler) {
        self.initialResult = initialResult
        self.nextPartialResult = nextPartialResult
    }
    
}

public struct ReducingParametersWithIndex<I, R>: ReducingParameters {
    
    public typealias Input = I
    public typealias Result = R
    public typealias NextPartialResultHandler = (Result, Input, Int) -> (Result)
    
    public let initialResult: Result
    public let nextPartialResult: NextPartialResultHandler
    
    public init(initialResult: Result, nextPartialResult: @escaping NextPartialResultHandler) {
        self.initialResult = initialResult
        self.nextPartialResult = nextPartialResult
    }
    
}
