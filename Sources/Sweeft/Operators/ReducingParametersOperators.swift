//
//  ReducingParametersOperators.swift
//  Pods
//
//  Created by Mathias Quintero on 12/7/16.
//
//

import Foundation

public func **<P: ReducingParameters>(_ nextPartialResult: P.NextPartialResultHandler, _ initialResult: P.Result) -> P {
    return P(initialResult: initialResult, nextPartialResult: nextPartialResult)
}

public func **<P: ReducingParameters>(_ initialResult: P.Result, _ nextPartialResult: P.NextPartialResultHandler) -> P {
    return nextPartialResult ** initialResult
}

public func ==><C: Collection, R>(_ items: C, _ reducingParameters: RegularReducingParameters<C.Iterator.Element, R>) -> R {
    return items.reduce(reducingParameters.initialResult, reducingParameters.nextPartialResult)
}

public func ==><I, R>(_ items: [I], _ reducingParameters: ReducingParametersWithIndex<I, R>) -> R {
    return items.reduce(reducingParameters.initialResult, reducingParameters.nextPartialResult)
}

prefix operator >

public prefix func ><P: ReducingParameters where P.Result: Defaultable>(_ nextPartialResult: P.NextPartialResultHandler) -> P {
    return P.Result.defaultValue ** nextPartialResult
}
