//
//  MultiformData.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/22/17.
//  Copyright © 2017 Mathias Quintero. All rights reserved.
//

import Foundation

public struct MultiformFile {
    
    public let data: Data
    public let mimeType: String
    
    public init(data: Data, mimeType: String) {
        self.data = data
        self.mimeType = mimeType
    }
    
}

public struct MultiformData {
    
    fileprivate var parameters: [String : CustomStringConvertible]
    fileprivate var boundary: String
    fileprivate var files: [String : MultiformFile]
    
    public init(parameters: [String : CustomStringConvertible] = .empty,
                boundary: String = UUID().uuidString,
                files: [String : MultiformFile] = .empty) {
        
        self.parameters = parameters
        self.boundary = boundary
        self.files = files
    }
    
}

extension MultiformData {
    
    public subscript(key: String) -> String? {
        get {
            return parameters[key]?.description
        }
        set {
            parameters[key] = newValue
        }
    }
    
    public subscript(key: String) -> MultiformFile? {
        get {
            return files[key]
        }
        set {
            files[key] = newValue
        }
    }
    
}

extension MultiformData: DataSerializable {
    
    public var contentType: String? {
        return "multipart/form-data; boundary=\(boundary)"
    }
    
    public var data: Data? {
        let parametersData = parameters.reduce(Data()) { data, item in
            return data.appending(string: "--\(boundary)\r\n")
                .appending(string: "Content-Disposition: form-data; name=\"\(item.key)\"\r\n\r\n")
                .appending(string: "\(item.value)\r\n")
        }
        let fileData = files.reduce(parametersData) { data, item in
            return data.appending(string: "--\(boundary)\r\n")
                .appending(string: "Content-Disposition: form-data; name=\"file\"; filename=\"\(item.key)\"\r\n")
                .appending(string: "Content-Type: \(item.value.mimeType)\r\n\r\n")
                .appending(item.value.data)
                .appending(string: "\r\n")
        }
        return fileData.appending(string: "--\(boundary)--\r\n")
    }
    
}
