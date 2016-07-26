//
//  AppDelegate.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import CocoaLumberjack
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        self.setupLogging()
        
        // Always show statusbar
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        
        // Setup Data Model - Realm
        let realm = try! Realm()
        
        // Create default realm if necessary
        checkAndCreateDefaultLens()
        
        // Pass realm to main VC
        if let rootVC = self.window?.rootViewController as? MainViewController
        {
            rootVC.realm = realm
        }
        
        Fabric.with([Crashlytics.self])
        return true
    }
    
    // MARK: Helpers
    
    private func setupLogging()
    {
        // Logging
        #if RELEASE
            defaultDebugLevel = DDLogLevel.Verbose
        #else
            defaultDebugLevel = DDLogLevel.Verbose
        #endif
        
        // TTY Logging
        setenv("XcodeColors", "YES", 0)
        let logger = DDTTYLogger.sharedInstance()
        logger.setXcodeColors()
        logger.logFormatter = CustomLogFormatter()
        DDLog.addLogger(logger)
        
        // Add Crashlytics remote logging
        let crashlyticsLogger = CrashlyticsLogger.sharedInstance
        crashlyticsLogger.logFormatter = CustomLogFormatter()
        DDLog.addLogger(crashlyticsLogger)
    }
}

