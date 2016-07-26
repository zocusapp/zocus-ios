//
//  ActivePeripheral.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - Equatable
func ==(lhs: ActivePeripheral, rhs: ActivePeripheral) -> Bool
{
    return lhs.hashValue == rhs.hashValue
}

// MARK: - Hashable
extension ActivePeripheral : Hashable
{
    var hashValue : Int {
        get {
            return self.cbPeripheral.hashValue
        }
    }
}

// MARK: - Active Peripheral
struct ActivePeripheral
{
    var cbPeripheral : CBPeripheral
    var objPeripheral : Peripheral
    
    init(cb: CBPeripheral, obj: Peripheral)
    {
        self.cbPeripheral = cb
        self.objPeripheral = obj
    }
}
