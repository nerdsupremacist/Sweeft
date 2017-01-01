//
//  JSON.swift
//  Pods
//
//  Created by Mathias Quintero on 12/21/16.
//
//

import Foundation

public enum JSON {
    
    case dict([String:JSON])
    case array([JSON])
    case string(String)
    case bool(Bool)
    case double(Double)
    case object(Serializable)
    case null
    
    public subscript(key: String) -> JSON {
        return dict | key ?? .null
    }
    
    public subscript(index: Int) -> JSON {
        return array | index ?? .null
    }
    
}

public extension JSON {
    
    var value: Any {
        switch self {
        case .dict(let value):
            return value
        case .array(let value):
            return value
        case .string(let value):
            return value
        case .bool(let value):
            return value
        case .double(let value):
            return value
        case .object(let value):
            return value
        case .null:
            return NSNull()
        }
    }
    
    func get<T>() -> T? {
        guard let item = value as? T else {
            return nil
        }
        return item
    }
    
    public func get<T>(in path: [String], using mapper: (JSON) -> T?) -> T? {
        if let key = path.first {
            return self[key].get(in: path || [0], using: mapper)
        }
        return mapper(self)
    }
    
    public func get<T: Deserializable>(in path: [String]) -> T? {
        return get(in: path, using: T.init)
    }
    
    public func get<T: Deserializable>(in path: String...) -> T? {
        return get(in: path)
    }
    
    public func getAll<T>(in path: [String], using mapper: (JSON) -> T?) -> [T]? {
        if let key = path.first {
            return self[key].getAll(in: path || [0], using: mapper)
        }
        guard let array = array else {
            return nil
        }
        return array ==> mapper
    }
    
    public func getAll<T: Deserializable>(in path: [String], for internalPath: [String] = []) -> [T]? {
        return getAll(in: path, using: T.initializer(for: internalPath))
    }
    
    public func getAll<T: Deserializable>(in path: String...) -> [T]? {
        return getAll(in: path)
    }
    
}

extension JSON {
    
    public var serialized: JSON {
        switch self {
        case .object(let value):
            return value.json
        case .array(let value):
            return .array(value => { $0.serialized })
        case .dict(let value):
            return .dict(value >>= {
                ($0, $1.serialized)
            })
        default:
            return self
        }
    }
    
    public var object: Any {
        let json = self.serialized
        switch json {
        case .array(let value):
            return value => { $0.object }
        case .dict(let value):
            return value >>= {
                ($0.0, $0.1.object)
            }
        default:
            return json.value
        }
    }
    
}

extension JSON {
    
    public var string: String? {
        let value: CustomStringConvertible? = get()
        return value?.description
    }
    
    public var int: Int? {
        return double | Int.init
    }
    
    public var double: Double? {
        return get()
    }
    
    public var bool: Bool? {
        return get()
    }
    
    public var array: [JSON]? {
        return get()
    }
    
    public var dict: [String:JSON]? {
        return get()
    }
    
    public func date(using format: String = "dd.MM.yyyy hh:mm:ss a") -> Date? {
        return string?.date(using: format)
    }
    
}

extension JSON {
    
    public init?(from value: Any) {
        if let dictionary = value as? [String:Any] {
            let dict = dictionary.dictionaryWithoutOptionals { ($0, JSON(from: $1)) }
            self = .dict(dict)
            return
        }
        if let array = value as? [Any] {
            self = .array(array ==> JSON.init)
            return
        }
        if let string = value as? String {
            self = .string(string)
            return
        }
        if let double = value as? Double {
            self = .double(double)
            return
        }
        return nil
    }
    
    public init?(data: Data, options: JSONSerialization.ReadingOptions) {
        guard let data = try? JSONSerialization.jsonObject(with: data, options: options) else {
            return nil
        }
        self.init(from: data)
    }
    
}

extension JSON: DataRepresentable {
    
    public init?(data: Data) {
        self.init(data: data, options: .allowFragments)
    }
    
}

extension JSON: DataSerializable {
    
    public var data: Data? {
        let object = self.object
        return try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
    }
    
}

extension JSON: Serializable {
    
    public var json: JSON {
        return self
    }
    
}
