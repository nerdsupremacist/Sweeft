//
//  Cache.swift
//  Pods
//
//  Created by Mathias Quintero on 5/12/17.
//
//

import Foundation

public protocol Cache {
    associatedtype Value
    func get(with identifier: String, maxTime: TimeInterval) -> Value?
    func store(_ data: Value, with identifier: String)
    func delete(at identifier: String)
}

public struct FileCache {
    
    public let directory: String
    
}

extension FileCache: Cache {
    
    private var fileManager: FileManager {
        return .default
    }
    
    private var searchPathURL: URL {
        let urls = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        return urls[urls.count - 1].appendingPathComponent(directory)
    }
    
    private func url(for identifier: String) -> URL {
        return searchPathURL.appendingPathComponent(identifier)
    }
    
    public func get(with identifier: String, maxTime: TimeInterval) -> Data? {
        let fileURL = url(for: identifier)
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            guard let lastUpdated = attributes[FileAttributeKey.modificationDate] as? Date else {
                return nil
            }
            guard Date.now.timeIntervalSince(lastUpdated) < maxTime else {
                delete(at: identifier)
                return nil
            }
            return try Data(contentsOf: fileURL)
        } catch {
            return nil
        }
    }
    
    public func store(_ data: Data, with identifier: String) {
        let fileURL = url(for: identifier)
        do {
            if !fileManager.fileExists(atPath: searchPathURL.path) {
                try fileManager.createDirectory(at: searchPathURL, withIntermediateDirectories: true, attributes: nil)
            }
            try data.write(to: fileURL, options: .atomic)
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    public func delete(at identifier: String) {
        try? fileManager.removeItem(at: url(for: identifier))
    }
    
}
