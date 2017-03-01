//
//  OAuthDelegate.swift
//  Pods
//
//  Created by Mathias Quintero on 3/1/17.
//
//

import Foundation

public protocol OAuthDelegate {
    func didRefresh(replace old: OAuth, with new: OAuth)
}
