//
//  Peripheral.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Equatable
func ==(lhs: Peripheral, rhs: Peripheral) -> Bool
{
    return lhs.serviceUUID?.hashValue == rhs.serviceUUID?.hashValue
}

// MARK: - Hashable
extension Peripheral : Hashable
{
    var hashValue : Int {
        get {
            return self.name!.hashValue
        }
    }
}

struct Peripheral
{
    var name: String?
    var serviceUUID: String?
}
