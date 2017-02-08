//
//  Constraint.swift
//  Pods
//
//  Created by Mathias Quintero on 2/8/17.
//
//

import Foundation

public protocol CSPValue {
    static var all: [Self] { get }
}

/// Models a Contraint in a CSP
public enum Contraint<Variable: Hashable, Value: CSPValue>  {
    case unary(Variable, contraint: (Value) -> Bool)
    case binary(Variable, Variable, contraint: (Value, Value) -> Bool)
}

extension Contraint {
    
    var variables: [Variable] {
        switch self {
        case .unary(let variable, _):
            return [variable]
        case .binary(let lhs, let rhs, _):
            return [lhs, rhs]
        }
    }
    
}

extension Contraint {
    
    private func values<Variable: Hashable, Value: CSPValue>(for variable: Variable, in array: [VariableInstance<Variable, Value>]) -> [Value] {
        let matching = array >>= { $0.variable } <+> { $0.values }
        return matching[variable].?
    }
    
    func works(with instances: [VariableInstance<Variable, Value>]) -> Bool {
        switch self {
        case .unary(let variable, let constraint):
            return values(for: variable, in: instances).and(conjunctUsing: constraint)
        case .binary(let lhs, let rhs, let constraint):
            let lhs = values(for: lhs, in: instances)
            let rhs = values(for: rhs, in: instances)
            return lhs.or(disjunctUsing: { constraint ** $0 } >>> rhs.or)
        default:
            return false
        }
    }
    
}
