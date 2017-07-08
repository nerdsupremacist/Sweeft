//
//  Cache.swift
//  Pods
//
//  Created by Mathias Quintero on 5/12/17.
//
//

import Foundation

public enum CacheTime {
    case no
    case time(TimeInterval)
    case forever
}

extension CacheTime: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: TimeInterval) {
        if value <= 0 {
            self = .no
        } else {
            self = .time(value)
        }
    }
    
}

extension CacheTime {
    
    func isCreationDateValid(date: Date) -> Bool {
        switch self {
        case .no:
            return false
        case .forever:
            return true
        case .time(let time):
            return Date.now.timeIntervalSince(date) < time
        }
    }
    
}

extension CacheTime: Equatable {
    
    public static func ==(_ lhs: CacheTime, _ rhs: CacheTime) -> Bool {
        switch (lhs, rhs) {
        case (.no, .no):
            return true
        case (.forever, .forever):
            return true
        case (.time(let a), .time(let b)):
            return a == b
        default:
            return false
        }
    }
    
}

public protocol Cache {
    associatedtype Value
    func get(with identifier: String, maxTime: CacheTime) -> Value?
    func store(_ data: Value, with identifier: String)
    func delete(at identifier: String)
}

public struct FileCache {
    
    public let directory: String
    
    public init(directory: String) {
        self.directory = directory
    }
    
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
    
    public func get(with identifier: String, maxTime: CacheTime) -> Data? {
        let fileURL = url(for: identifier)
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            guard let lastUpdated = attributes[FileAttributeKey.modificationDate] as? Date else {
                return nil
            }
            guard maxTime.isCreationDateValid(date: lastUpdated) else {
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
