//
//  Binding.swift
//  Pods
//
//  Created by Mathias Quintero on 12/26/16.
//
//

import Foundation

public struct Binding<T: Observable, O> {
    
    var value: T
    let mapping: (T) -> O
    
    mutating func apply(to handler: @escaping (O) -> ()) {
        let mapping = self.mapping
        value | mapping | handler
        value.onChange(do: mapping >>> handler)
    }
    
}

extension Binding {
    
    init<C: ObservableContainer where C.ObservableItem == T>(container: C, mapping: @escaping (T) -> (O)) {
        self.init(value: container.observable, mapping: mapping)
    }
    
}

public func **<T: Observable, O>(_ value: T?, _ mapping: @escaping (T) -> (O)) -> Binding<T, O>? {
    guard let value = value else {
        return nil
    }
    return Binding(value: value, mapping: mapping)
}

public func **<C: ObservableContainer, O>(_ container: C?, _ mapping: @escaping (C.ObservableItem) -> (O)) -> Binding<C.ObservableItem, O>? {
    guard let container = container else {
        return nil
    }
    return Binding(container: container, mapping: mapping)
}

public func >>><T: Observable, O>(_ binding: Binding<T, O>?, _ handler: @escaping (O) -> ()) {
    var binding = binding
    binding?.apply(to: handler)
}

public func >>><T: Observable>(_ value: T?, _ handler: @escaping (T) -> ()) {
    value ** id >>> handler
}

public func >>><C: ObservableContainer>(_ value: C?, _ handler: @escaping (C.ObservableItem) -> ()) {
    value ** id >>> handler
}

public func >>><C: Collection where C.Iterator.Element: Observable>(_ items: C, _ handler: @escaping (C.Iterator.Element) -> ()) {
    items => { $0 >>> handler }
}

public func >>><C: Collection where C.Iterator.Element: ObservableContainer>(_ items: C, _ handler: @escaping (C.Iterator.Element.ObservableItem) -> ()) {
    items => { $0 >>> handler }
}

public func >>><T: Observable>(_ items: [T], _ handlers: [(T) -> ()]) {
    guard items.count == handlers.count else {
        return
    }
    handlers => {
        (items | $1) >>> $0
    }
}
