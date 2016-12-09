//
//  Other.swift
//  Pods
//
//  Created by Mathias Quintero on 12/9/16.
//
//

import Foundation

/**
 Will return whatever you give it. Useful to replace '{ $0 }' and make the code more approachable and friendly ;)
 
 - Parameters:
    - value: value
 
 - Returns: value
 */
func id<T>(_ value: T) -> T {
    return value
}

/**
 Will return the first argument you give it. Let type inference do what you need it to do. 
 (Be careful with type inference)
 
 - Parameters:
    - argOne: value
    - argTwo: value you want to ignore
 
 - Returns: argOne
 */
func firstArgument<T, V>(_ argOne: T, _ argTwo: V) -> T {
    return argOne
}

/**
 Will return the last argument you give it. Let type inference do what you need it to do.
 (Be careful with type inference)
 
 - Parameters:
    - argOne: value you want to ignore
    - argTwo: value
 
 - Returns: argTwo
 */
func lastArgument<T, V>(_ argOne: T, _ argTwo: V) -> V {
    return argTwo
}

/**
 Will return the middle argument you give it. Let type inference do what you need it to do.
 (Be careful with type inference. Really careful with this one!!!)
 
 - Parameters:
    - argOne: value you want to ignore
    - argTwo: value
    - argThree: value you want to ignore
 
 - Returns: argTwo
 */
func middleArgument<T, V, Z>(_ argOne: T, _ argTwo: V, _ argThree: Z) -> V {
    return argTwo
}

func flipArguments<T, V>(_ argOne: T, _ argTwo: V) -> (V, T) {
    return (argTwo, argOne)
}
