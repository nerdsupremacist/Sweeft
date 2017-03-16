//
//  AppDelegate.swift
//  Sweeft
//
//  Created by Mathias Quintero on 11/20/2016.
//  Copyright (c) 2016 Mathias Quintero. All rights reserved.
//

import UIKit
import Sweeft

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let w = true
        let p = false
        
        let maze: Maze = [
            [w, w, w, w, p, w, w, w],
            [w, w, p, p, p, p, p, p],
            [w, p, p, w, w, p, w, p],
            [w, p, w, w, w, p, w, p],
            [p, p, p, w, w, p, w, w],
            [p, w, p, p, p, p, w, w],
            [p, w, w, p, w, w, w, w],
            [p, w, w, p, p, p, p, p],
            [p, p, p, w, w, w, w, p],
            [w, w, p, p, p, p, p, p],
            [w, w, w, w, w, w, w, p]
        ]
        let start = Maze.Coordinates(x: 4, y: 0)
        let end = Maze.Coordinates(x: 7, y: 10)
        if let path = maze.findWay(from: start, to: end) {
            print(path.join(with: "\n"))
        }
        
        async(self.superLongFunction).onSuccess { result in
            print(result)
        }
        .onError { error in
            print(error)
        }
        
//        
//        Demo.colorMap()
//        Demo.solveQueensProblem()
        
        // Override point for customization after application launch.
        return true
    }
    
    func superLongFunction() -> Int {
        return 42
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

