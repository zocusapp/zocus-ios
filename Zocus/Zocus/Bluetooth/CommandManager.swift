//
//  CommandManager.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation

private let DevicePlistName = "Devices"

class CommandManager: NSObject
{
    enum Commands : String
    {
        case OnOff = "OnOff"
        case Stop = "Stop"
    }
    
    static let allValues : [Commands] = [.OnOff, .Stop]
    
    fileprivate (set) var devicesDictionary : [String : AnyObject]!
    
    var availableServices : [String]? {
        get {
            return Array(self.devicesDictionary.keys)
        }
    }
    
    var availableWriteCharacteristics : [String]? {
        get {
            var writeCharacteristicStrings : [String] = []
            for (_, value) in self.devicesDictionary
            {
                if let writeCharacteristic = value["WriteCharacteristic"] as? String
                {
                    writeCharacteristicStrings.append(writeCharacteristic)
                }
            }
            return writeCharacteristicStrings
        }
    }
    
    override init() {}
    
    init(devicePlistName: String)
    {
        super.init()
        self.loadCommandsForServiceUUIDs(devicePlistName)
    }

    func getManufacturerForServiceUUID(_ serviceUUID: String) -> String?
    {
        if let serviceDict = self.devicesDictionary[serviceUUID] as? [String : AnyObject],
            let mft = serviceDict["Manufacturer"] as? String
        {
            return mft
        }
        else
        {
            return nil
        }
    }
    
    func getCommandCodeForServiceUUIDAndCommandString(_ serviceUUID: String, command: Commands) -> String?
    {
        let commandString = command.rawValue
        if let serviceDict = self.devicesDictionary[serviceUUID] as? [String : AnyObject],
            let commands = serviceDict["Commands"] as? [String : String],
            let commandCode = commands[commandString]
        {
            return commandCode
        }
        else
        {
            return nil
        }
    }
    
    // Load in to memory the commands and service uuids for all devices app can utilise
    fileprivate func loadCommandsForServiceUUIDs(_ devicePlistName: String = DevicePlistName)
    {
        if let path = Bundle.main.path(forResource: devicePlistName, ofType: "plist"),
            let devicesDict = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        {
            self.devicesDictionary = devicesDict
        }
        else
        {
            log.error("Could not load \(DevicePlistName) settings")
            abort()
        }
    }
}



