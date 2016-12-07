//
//  AppDelegate.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Setup Data Model - Realm
        let realm = try! Realm()
        
        // Create default realm if necessary
        checkAndCreateDefaultLens()
        
        // Pass realm to main VC
        if let rootVC = self.window?.rootViewController as? MainViewController
        {
            rootVC.realm = realm
        }
        return true
    }
}

