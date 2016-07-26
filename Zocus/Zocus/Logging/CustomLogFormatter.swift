//
//  CustomLogFormatter.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import CocoaLumberjack

class CustomLogFormatter : NSObject, DDLogFormatter
{
    private var loggerCount = 0
    private var dateFormatter : NSDateFormatter!
    
    override init()
    {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    }
    
    func formatLogMessage(logMessage: DDLogMessage!) -> String!
    {
        var logLevel : String!
        switch (logMessage.flag)
        {
        case DDLogFlag.Error:
            logLevel = "Error"
        case DDLogFlag.Warning:
            logLevel = "Warning"
        case DDLogFlag.Info:
            logLevel = "Info"
        case DDLogFlag.Debug:
            logLevel = "Debug"
        case DDLogFlag.Verbose:
            logLevel = "Verbose"
        default:
            logLevel = "All"
        }
        
        let dateAndTime = self.dateFormatter.stringFromDate(logMessage.timestamp)
        let formattedString = "\(dateAndTime) [\(logLevel)] \(logMessage.function)(\(logMessage.line)): \(logMessage.message)"
        return formattedString
    }
    
    func didAddToLogger(logger: DDLogger!)
    {
        self.loggerCount += 1
    }
    
    func willRemoveFromLogger(logger: DDLogger!)
    {
        self.loggerCount -= 1
    }
}