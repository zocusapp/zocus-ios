//
//  Logging.swift
//  Zocus
//
//  Created by Akram Hussein on 07/12/2016.
//
//

import XCGLogger

let log : XCGLogger = {
    let log = XCGLogger.default
    
    var logLevel : XCGLogger.Level = .verbose
    #if RELEASE
        logLevel = .Error
    #endif
    
    // TTY Logging
    setenv("XcodeColors", "YES", 0)
    
    log.setup(level: logLevel,
              showLogIdentifier: false,
              showFunctionName: true,
              showThreadName: false,
              showLevel: true,
              showFileNames: true,
              showLineNumbers: true,
              showDate: true,
              writeToFile: nil,
              fileLevel: nil)
    
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    dateFormatter.locale = Locale.current
    log.dateFormatter = dateFormatter
    
    return log
}()
