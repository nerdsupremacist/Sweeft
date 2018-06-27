//
//  Keychain.swift
//  Pods
//
//  Created by Mathias Quintero on 4/29/17.
//
//

import Foundation
import Security

struct Keychain: StorageItem {
    
    static let standard = Keychain()
    
    func delete(at key: String) {
        
        let query: [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : key,
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    func set<C>(_ value: C?, forKey defaultName: String) where C : Codable {
        
        guard let value = value else {
            return delete(at: defaultName)
        }
        
        let encoder = PropertyListEncoder()
        
        guard let data = try? encoder.encode(value) else {
            return delete(at: defaultName)
        }
        
        let query: [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : defaultName,
            ]
        
        let dataQuery: [String : Any] = [
            kSecAttrService as String : defaultName,
            kSecValueData as String : data,
            ]
        
        let status = SecItemUpdate(query as CFDictionary, dataQuery as CFDictionary)
        
        if status == errSecItemNotFound {
            
            let createQuery: [String : Any] = [
                kSecClass as String : kSecClassGenericPassword,
                kSecAttrService as String : defaultName,
                kSecValueData as String : data,
                kSecAttrAccessible as String : kSecAttrAccessibleWhenUnlocked,
                ]
            
            SecItemAdd(createQuery as CFDictionary, nil)
        }
    }
    
    func object<C>(forKey defaultName: String) -> C? where C : Codable {
        
        var result: CFTypeRef?
        
        let query: [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : defaultName,
            kSecMatchLimit as String : kSecMatchLimitOne,
            kSecReturnData as String : kCFBooleanTrue,
            ]
        
        
        let status = withUnsafeMutablePointer(to: &result) { pointer in
            
            return SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(pointer))
        }
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        let decoder = PropertyListDecoder()
        return try? decoder.decode(C.self, from: data)
    }
    
}

