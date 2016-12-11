//
//  LastDateOpened.swift
//  Sweeft
//
//  Created by Mathias Quintero on 12/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Sweeft

enum AppDefaults: String, StatusKey {
    case lastDate
}

struct LastDateOpened: Status {
    static let key: AppDefaults = .lastDate
    static let defaultValue: Date? = nil
}
