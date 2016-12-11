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
    func string(using format: String = "dd.MM.yyyy hh:mm") -> String {
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

/// Struct representing a difference between two dates
public struct DateDifference {
    
    /// Left date
    let first: Date
    /// Right date
    let second: Date
    
    private func difference(by granularity: Calendar.Component) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let set = [granularity].set
        let components = calendar.dateComponents(set, from: second, to: first)
        return components.value(for: granularity).?
    }
    
    /// Regular TimeInterval between the two dates
    var timeInterval: TimeInterval {
        return first.timeIntervalSince(second)
    }
    
    /// The change in timezones
    var timeZones: Int {
        return difference(by: .timeZone)
    }
    
    /// The difference in nanoseconds
    var nanoSeconds: Int {
        return difference(by: .nanosecond)
    }
    
    /// The difference in seconds
    var seconds: Int {
        return difference(by: .second)
    }
    
    /// The difference in minutes
    var minute: Int {
        return difference(by: .minute)
    }
    
    /// The difference in hours
    var hours: Int {
        return difference(by: .hour)
    }
    
    /// The difference in days
    var days: Int {
        return difference(by: .day)
    }
    
    /// The difference in weeks
    var weeks: Int {
        return difference(by: .weekdayOrdinal)
    }
    
    /// The difference in years
    var years: Int {
        return difference(by: .year)
    }
    
    /// The difference in millenia. For some reason
    var millenia: Int {
        return years / 1000
    }
    
    
}
