//
//  DependecyGraph.swift
//  Sweeft_Example
//
//  Created by Mathias Quintero on 7/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Sweeft

//struct Version {
//    let major: Int
//    let minor: Int
//    let patch: Int
//}
//
//struct App {
//    let name: String
//    let dependencies: [Dependency]
//}
//
//struct Component {
//    let name: String
//    let versions: [Resolved]
//}
//
//struct Resolved {
//    let version: Version
//    let dependencies: [Dependency]
//}
//
//struct Dependency {
//    let component: Component
//    let resolved: Resolved
//}
//
//extension Version {
//    
//    func compatible(with other: Version) -> Bool {
//        if self.major != other.major {
//            return false
//        }
//        if self.minor != other.minor {
//            return false
//        }
//        return true
//    }
//    
//}
//
//extension Component: Hashable {
//    
//    var hashValue: Int {
//        return name.hashValue
//    }
//    
//    static func ==(lhs: Component, rhs: Component) -> Bool {
//        return lhs.name == rhs.name
//    }
//    
//}
//
//extension App {
//    
//    var components: [Component] {
//        let components = self.dependencies.flatMap { $0.components }
//        return components.noDuplicates
//    }
//    
//}
//
//extension Dependency {
//    
//    var components: [Component] {
//        let components = [self.component] + resolved.dependencies.flatMap { $0.components }
//        return components.noDuplicates
//    }
//    
//}
//
//extension App {
//    
//    func resolve() -> [Dependency] {
//        let components = self.components
//        let contraints = components => { component in
//            return component.
//        }
//    }
//    
//}

