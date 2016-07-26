//
//  BluetoothDeviceManager.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreData
import UIKit

@objc
protocol BluetoothDeviceManagerDelegate
{
    optional func peripheralFound(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber)
    
    optional func bluetoothManagerFinishedScanning(bluetoothManager: BluetoothDeviceManager)
    
    optional func peripheralConnected(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral)
    
    optional func peripheralDisconnected(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral)
}

// MARK: - Constants

private let ScanTime = 10.0

class BluetoothDeviceManager: NSObject
{
    static let sharedInstance = BluetoothDeviceManager()
    
    // MARK: - Shared instances
    let commandManager = CommandManager(devicePlistName: "Devices")
    
    private var centralManager : CBCentralManager!
    private var bluetoothOn = false
    private (set) var peripherals = Set<CBPeripheral>()
    
    var reconnectIfDisconnected = false
    
    // List of acceptable UUIDs for services & characteristics
    private (set) var availableServiceCBUUIDs = [CBUUID]()
    private (set) var availableWriteCharacteristicCBUUIDs = [CBUUID]()
    
    private (set) var characteristicsForPeripheral = [CBPeripheral : CBCharacteristic]()
    
    var scanTimer = NSTimer()
    
    // Delegate
    var delegate : BluetoothDeviceManagerDelegate?
    
    override init()
    {
        super.init()
        
        // Load available services
        self.loadAvailableServices()
        
        // Load available characterstics
        self.loadAvailableWriteCharacteristics()
        
        // Init CB Central Manager
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func loadAvailableServices()
    {
        if let availableServices = self.commandManager.availableServices
        {
            for service in availableServices
            {
                self.availableServiceCBUUIDs.append(CBUUID(string: service))
            }
        }
        
        print("DEBUG: Acceptable service UUIDs: \(self.availableServiceCBUUIDs)")
    }
    
    func loadAvailableWriteCharacteristics()
    {
        if let availableWriteCharacteristics = self.commandManager.availableWriteCharacteristics
        {
            for writeCharacteristic in availableWriteCharacteristics
            {
                self.availableWriteCharacteristicCBUUIDs.append(CBUUID(string: writeCharacteristic))
            }
        }
        
        print("DEBUG: Acceptable write characterisic UUIDs: \(self.availableWriteCharacteristicCBUUIDs)")
    }
    
    
    // MARK: - Bluetooth Functions
    
    func searchForDevices(time: Double)
    {
        // Cancel any previous requests to stop this
        self.scanTimer.invalidate()
        
        // Scan for devices
        self.startSearchingForDevices()
        
        // Create time
        self.scanTimer = NSTimer.scheduledTimerWithTimeInterval(time,
                                                                target: self,
                                                                selector: #selector(BluetoothDeviceManager.stopSearchingForDevices),
                                                                userInfo: nil,
                                                                repeats: false)
    }
    
    func startSearchingForDevices()
    {
        print("DEBUG: Start searching for devices")
        
        if (self.centralManager.state == .PoweredOn)
        {
            if (self.availableServiceCBUUIDs.count > 0)
            {
                self.centralManager.scanForPeripheralsWithServices(self.availableServiceCBUUIDs, options: nil)
            }
            else
            {
                print("DEBUG: No available service UUIDs to scan")
            }
        }
        else
        {
            // Perhaps throw error?
            print("DEBUG: Bluetooth not powered on, unable to scan for peripherals")
        }
    }
    
    func stopSearchingForDevices()
    {
        print("DEBUG: Stop searching for devices")
        
        print("DEBUG: Found \(self.peripherals)")
        
        self.centralManager.stopScan()
        
        self.delegate?.bluetoothManagerFinishedScanning?(self)
    }
    
    func connectToPeripherals(peripherals: [CBPeripheral])
    {
        for peripheral in peripherals
        {
            print("DEBUG: Connecting to peripheral \(peripheral.name) - \(peripheral.identifier.UUIDString)")
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func disconnectFromPeripherals(peripherals: [CBPeripheral])
    {
        for peripheral in peripherals
        {
            print("DEBUG: Disconnecting from peripheral \(peripheral.name) - \(peripheral.identifier.UUIDString)")
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    private func compareCBUUID(uuid1: CBUUID, uuid2: CBUUID) -> Bool
    {
        return (uuid1.UUIDString == uuid2.UUIDString)
    }
    
    private func findServiceFromUUID(uuid: CBUUID, peripheral: CBPeripheral) -> CBService?
    {
        for service in peripheral.services!
        {
            return self.compareCBUUID(service.UUID, uuid2: uuid) ? service : nil
        }
        return nil
    }
    
    private func findCharacteristicFromUUID(uuid: CBUUID, service: CBService) -> CBCharacteristic?
    {
        for characteristic in service.characteristics!
        {
            return self.compareCBUUID(characteristic.UUID, uuid2: uuid) ? characteristic : nil
        }
        return nil
    }
    
    private func getAllServicesFromPeripheral(peripheral: CBPeripheral)
    {
        peripheral.discoverServices(nil)
    }
    
    private func getAllCharacteristicsFromPeripheral(peripheral: CBPeripheral)
    {
        let cbuuids = peripheral.services!.map{ $0.UUID }
        peripheral.discoverServices(cbuuids)
    }
    
    func sendCommand(peripheral: CBPeripheral, command: String)
    {
        // Fetch cached characteristic for peripheral
        if let characteristic = self.characteristicsForPeripheral[peripheral]
        {
            if let cmd = Int(command)
            {
                let buffer = [cmd]
                let data = NSData(bytes: buffer, length: 1)
                
                print("DEBUG: Sending Command: \(command), Data: \(data.description)")
                peripheral.writeValue(data, forCharacteristic: characteristic, type: .WithoutResponse)
            }
            else
            {
                print("ERROR: Cannot translate command \(command) to Int")
            }
        }
        else
        {
            print("ERROR: Could not find CBCharacteristic for CBPeripheral \(peripheral.identifier.UUIDString)")
        }
    }
    
}

// MARK: - CBCentralManagerDelegate

extension BluetoothDeviceManager : CBCentralManagerDelegate
{
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        switch (central.state)
        {
        case .PoweredOn:
            print("DEBUG: CoreBluetooth BLE hardware is powered on and ready")
            self.bluetoothOn = true
            self.searchForDevices(ScanTime)
            
        case .PoweredOff:
            print("DEBUG: CoreBluetooth BLE hardware is powered off")
            self.bluetoothOn = false
            
        case .Resetting:
            print("DEBUG: CoreBluetooth BLE hardware is resetting")
            self.bluetoothOn = false
            
        case .Unauthorized:
            print("DEBUG: CoreBluetooth BLE state is unauthorized")
            self.bluetoothOn = false
            
        case .Unknown:
            print("DEBUG: CoreBluetooth BLE state is unknown")
            self.bluetoothOn = false
            
        case .Unsupported:
            print("DEBUG: CoreBluetooth BLE hardware is unsupported on this platform")
            self.bluetoothOn = false
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        print("DEBUG: Connected to peripheral: \(peripheral.identifier.UUIDString)")
        self.delegate?.peripheralConnected?(self, peripheral: peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("DEBUG: Lost connection to peripheral: \(peripheral.identifier.UUIDString)")
        
        self.delegate?.peripheralDisconnected?(self, peripheral: peripheral)
        
        if (self.reconnectIfDisconnected)
        {
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        print("DEBUG: Found peripheral: \(peripheral.identifier.UUIDString)")
        print("DEBUG: Advertisement Data: \(advertisementData.description)")
        print("DEBUG: Name: \(peripheral.name)")
        
        self.peripherals.insert(peripheral)
        
        print("DEBUG: Total scanned peripheral count: \(self.peripherals.count)")
        
        // Notify delegate of new peripheral found
        self.delegate?.peripheralFound?(self, peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("ERROR: Failed to connect to peripheral \(peripheral.identifier.UUIDString). Error: \(error?.localizedDescription)", terminator: "")
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothDeviceManager : CBPeripheralDelegate
{
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        if let services = peripheral.services
        {
            for service in services
            {
                peripheral.discoverCharacteristics(self.availableWriteCharacteristicCBUUIDs, forService: service )
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
    {
        
        for characteristic in service.characteristics!
        {
            self.characteristicsForPeripheral[peripheral] = characteristic
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
        if (error != nil)
        {
            print(error!.localizedDescription)
        }
    }
}