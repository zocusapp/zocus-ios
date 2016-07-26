//
//  ActivePeripheralsManager.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import CoreBluetooth

class ActivePeripheralsManager: NSObject
{
    static let sharedInstance = ActivePeripheralsManager()
    
    // Peripherals
    var selectedPeripherals = Set<ActivePeripheral>()
    var scannedPeripherals = Set<ActivePeripheral>()
    
    var selectedCBPeripherals : Set<CBPeripheral> {
        get {
            return Set(selectedPeripherals.map{$0.cbPeripheral})
        }
    }
    
    var selectedObjPeripherals : Set<Peripheral> {
        get {
            return Set(selectedPeripherals.map{$0.objPeripheral})
        }
    }
    
    var scannedCBPeripherals : Set<CBPeripheral> {
        get {
            return Set(scannedPeripherals.map{$0.cbPeripheral})
        }
    }
    
    var scannedObjPeripherals : Set<Peripheral> {
        get {
            return Set(scannedPeripherals.map{$0.objPeripheral})
        }
    }
    
    override init()
    {
        super.init()
    }
    
    func removeUnscannedPeripherals()
    {
        self.selectedPeripherals.intersectInPlace(self.scannedPeripherals)
    }

}