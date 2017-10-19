//
//  Storage.swift
//  Sweeft
//
//  Created by Mathias Quintero on 10/1/17.
//

import Foundation

public enum Storage {
    case userDefaults
    case keychain
    
    var object: StorageItem {
        switch self {
        case .userDefaults:
            return UserDefaults.standard
        default:
            return Keychain()
        }
        
    }
    
}

protocol StorageItem {
    func object<C: Codable>(forKey defaultName: String) -> C?
    func set<C: Codable>(_ value: C?, forKey defaultName: String)
}

extension UserDefaults: StorageItem {
    
    func object<C>(forKey defaultName: String) -> C? where C: Codable {
        
        guard let data = data(forKey: defaultName) else { return nil }
        let decoder = PropertyListDecoder()
        return try? decoder.decode(C.self, from: data)
    }
    
    func set<C>(_ value: C?, forKey defaultName: String) where C : Decodable, C : Encodable {
        
        guard let value = value else { return set(nil, forKey: defaultName) }
        let encoder = PropertyListEncoder()
        let data = try? encoder.encode(value)
        set(data, forKey: defaultName)
    }
    
}
