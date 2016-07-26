//
//  CrashlyticsLogger.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Crashlytics

class CrashlyticsLogger : DDAbstractLogger
{
    static let sharedInstance = CrashlyticsLogger()
    
    private var _logFormatter : DDLogFormatter?
    override var logFormatter: DDLogFormatter? {
        get {
            return _logFormatter
        }
        set {
            _logFormatter = newValue
        }
    }
    
    override func logMessage(logMessage: DDLogMessage)
    {
        if let formatter = self.logFormatter
        {
            let formattedMessage = formatter.formatLogMessage(logMessage)
            CLSLogv(formattedMessage, getVaList([]))
        }
        else
        {
            CLSLogv(logMessage.message, getVaList([]))
        }
    }
}