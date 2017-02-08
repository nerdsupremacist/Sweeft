//
//  CSP.swift
//  Pods
//
//  Created by Mathias Quintero on 2/8/17.
//
//

import Foundation

/// Moddels a Contraint Statisfaction Problem
public struct CSP<Variable: Hashable, Value: CSPValue> {
    let variables: [Variable]
    let constraints: [Contraint<Variable, Value>]
}

public extension CSP {
    
    public init(constraints: [Contraint<Variable, Value>]) {
        let variables = constraints.flatMap { $0.variables }
        self.init(variables: variables.noDuplicates,
                  constraints: constraints)
    }
    
}

extension CSP: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: Contraint<Variable, Value>...) {
        self.init(constraints: elements)
    }
    
}

extension CSP {
    
    typealias Instance = VariableInstance<Variable, Value>
    
    func constraints(concerning variables: Variable...) -> [Contraint<Variable, Value>] {
        return self.constraints |> { variables.and(conjunctUsing: $0.variables.contains) }
    }
    
    func neighbours(of variable: Variable) -> [Variable] {
        let variables = constraints(concerning: variable).flatMap { $0.variables } |> { $0 != variable }
        return variables.noDuplicates
    }
    
    private func neighbourInstances(of current: Instance, in instances: [Instance]) -> [Instance] {
        let variables = neighbours(of: current.variable)
        return instances |> { variables.contains($0.variable) }
    }
    
    private func bestInstance(for instances: [Instance]) -> Instance? {
        let left = instances |> { !$0.isSolved }
        if left.count == instances.count {
            return left.argmin { self.neighbours(of: $0.variable).count }
        } else {
            return left.argmin { $0.values.count }
        }
    }
    
    private func solve(instances: [Instance]) -> [Instance]? {
        if instances.and(conjunctUsing: { $0.isSolved }) {
            return instances
        }
        guard let current = bestInstance(for: instances) else {
            return nil
        }
        let harmed = neighbourInstances(of: current, in: instances)
        let instances = instances |> { !harmed.contains($0) && $0 != current }
        return current.values ==> nil ** { result, value in
            if let result = result {
                return result
            }
            let instances = instances + .solved(variable: current.variable, value: value)
            let other = harmed => { $0.removeImpossibleValues(regarding: instances + harmed,
                                                              and: self.constraints(concerning: $0.variable)) }
            return self.solve(instances: instances + other)
        }
    }
    
    /// Find a Solution for the problem
    public func solution() -> [Variable:Value]? {
        let instances = variables => Instance.unsolved <** Value.all
        let solution = solve(instances: instances as [Instance])
        return solution?.dictionaryWithoutOptionals { ($0.variable, $0.values.first) }
    }
    
}
