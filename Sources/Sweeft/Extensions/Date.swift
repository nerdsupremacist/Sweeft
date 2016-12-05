//
//  Date.swift
//
//  Created by Mathias Quintero on 11/20/16.
//  Copyright © 2016 Mathias Quintero. All rights reserved.
//

import Foundation

public extension Date {
    
    /**
     Will turn a Date into a readable format
     
     - Parameters:
        - with format: format in which you want the date (Optional: default is "dd:MM:yyyy hh:mm")
     
     - Returns: String representation of the date
     */
    func string(with format: String = "dd:MM:yyyy hh:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

extension Date: Defaultable {
    
    /// Default Value
    public static var defaultValue: Date {
        return Date()
    }
    
}
