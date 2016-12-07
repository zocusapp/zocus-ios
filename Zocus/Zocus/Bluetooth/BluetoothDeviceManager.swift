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
    @objc optional func peripheralFound(_ bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, advertisementData: [AnyHashable: Any]!, RSSI: NSNumber)
    
    @objc optional func bluetoothManagerFinishedScanning(_ bluetoothManager: BluetoothDeviceManager)
    
    @objc optional func peripheralConnected(_ bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral)
    
    @objc optional func peripheralDisconnected(_ bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral)
}

// MARK: - Constants

private let ScanTime = 10.0

class BluetoothDeviceManager: NSObject
{
    static let sharedInstance = BluetoothDeviceManager()
    
    // MARK: - Shared instances
    let commandManager = CommandManager(devicePlistName: "Devices")
    
    fileprivate var centralManager : CBCentralManager!
    fileprivate var bluetoothOn = false
    fileprivate (set) var peripherals = Set<CBPeripheral>()
    
    var reconnectIfDisconnected = false
    
    // List of acceptable UUIDs for services & characteristics
    fileprivate (set) var availableServiceCBUUIDs = [CBUUID]()
    fileprivate (set) var availableWriteCharacteristicCBUUIDs = [CBUUID]()
    
    fileprivate (set) var characteristicsForPeripheral = [CBPeripheral : CBCharacteristic]()
    
    var scanTimer = Timer()
    
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
        
        log.debug("Acceptable service UUIDs: \(self.availableServiceCBUUIDs)")
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
        
        log.debug("Acceptable write characterisic UUIDs: \(self.availableWriteCharacteristicCBUUIDs)")
    }
    
    
    // MARK: - Bluetooth Functions
    
    func searchForDevices(_ time: Double)
    {
        // Cancel any previous requests to stop this
        self.scanTimer.invalidate()
        
        // Scan for devices
        self.startSearchingForDevices()
        
        // Create time
        self.scanTimer = Timer.scheduledTimer(timeInterval: time,
                                                                target: self,
                                                                selector: #selector(BluetoothDeviceManager.stopSearchingForDevices),
                                                                userInfo: nil,
                                                                repeats: false)
    }
    
    func startSearchingForDevices()
    {
        log.debug("Start searching for devices")
        
        if (self.centralManager.state == .poweredOn)
        {
            if (self.availableServiceCBUUIDs.count > 0)
            {
                self.centralManager.scanForPeripherals(withServices: self.availableServiceCBUUIDs, options: nil)
            }
            else
            {
                log.debug("No available service UUIDs to scan")
            }
        }
        else
        {
            // Perhaps throw error?
            log.debug("Bluetooth not powered on, unable to scan for peripherals")
        }
    }
    
    func stopSearchingForDevices()
    {
        log.debug("Stop searching for devices")
        
        log.debug("Found \(self.peripherals)")
        
        self.centralManager.stopScan()
        
        self.delegate?.bluetoothManagerFinishedScanning?(self)
    }
    
    func connectToPeripherals(_ peripherals: [CBPeripheral])
    {
        for peripheral in peripherals
        {
            log.debug("Connecting to peripheral \(peripheral.name) - \(peripheral.identifier.uuidString)")
            self.centralManager.connect(peripheral, options: nil)
        }
    }
    
    func disconnectFromPeripherals(_ peripherals: [CBPeripheral])
    {
        for peripheral in peripherals
        {
            log.debug("Disconnecting from peripheral \(peripheral.name) - \(peripheral.identifier.uuidString)")
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    fileprivate func compareCBUUID(_ uuid1: CBUUID, uuid2: CBUUID) -> Bool
    {
        return (uuid1.uuidString == uuid2.uuidString)
    }
    
    fileprivate func findServiceFromUUID(_ uuid: CBUUID, peripheral: CBPeripheral) -> CBService?
    {
        for service in peripheral.services!
        {
            return self.compareCBUUID(service.uuid, uuid2: uuid) ? service : nil
        }
        return nil
    }
    
    fileprivate func findCharacteristicFromUUID(_ uuid: CBUUID, service: CBService) -> CBCharacteristic?
    {
        for characteristic in service.characteristics!
        {
            return self.compareCBUUID(characteristic.uuid, uuid2: uuid) ? characteristic : nil
        }
        return nil
    }
    
    fileprivate func getAllServicesFromPeripheral(_ peripheral: CBPeripheral)
    {
        peripheral.discoverServices(nil)
    }
    
    fileprivate func getAllCharacteristicsFromPeripheral(_ peripheral: CBPeripheral)
    {
        let cbuuids = peripheral.services!.map{ $0.uuid }
        peripheral.discoverServices(cbuuids)
    }
    
    func sendCommand(_ peripheral: CBPeripheral, command: String)
    {
        // Fetch cached characteristic for peripheral
        if let characteristic = self.characteristicsForPeripheral[peripheral]
        {
            if let cmd = Int(command)
            {
                let buffer = [cmd]
                let data = Data(from: buffer)
                
                print("DEBUG: Sending Command: \(command), Data: \(data.description)")
                peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            }
            else
            {
                log.error("Cannot translate command \(command) to Int")
            }
        }
        else
        {
            log.error("Could not find CBCharacteristic for CBPeripheral \(peripheral.identifier.uuidString)")
        }
    }
    
}

// MARK: - CBCentralManagerDelegate

extension BluetoothDeviceManager : CBCentralManagerDelegate
{
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch (central.state)
        {
        case .poweredOn:
            log.debug("CoreBluetooth BLE hardware is powered on and ready")
            self.bluetoothOn = true
            self.searchForDevices(ScanTime)
            
        case .poweredOff:
            log.debug("CoreBluetooth BLE hardware is powered off")
            self.bluetoothOn = false
            
        case .resetting:
            log.debug("CoreBluetooth BLE hardware is resetting")
            self.bluetoothOn = false
            
        case .unauthorized:
            log.debug("CoreBluetooth BLE state is unauthorized")
            self.bluetoothOn = false
            
        case .unknown:
            log.debug("CoreBluetooth BLE state is unknown")
            self.bluetoothOn = false
            
        case .unsupported:
            log.debug("CoreBluetooth BLE hardware is unsupported on this platform")
            self.bluetoothOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        log.debug("Connected to peripheral: \(peripheral.identifier.uuidString)")
        self.delegate?.peripheralConnected?(self, peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        log.debug("Lost connection to peripheral: \(peripheral.identifier.uuidString)")
        
        self.delegate?.peripheralDisconnected?(self, peripheral: peripheral)
        
        if (self.reconnectIfDisconnected)
        {
            self.centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        log.debug("Found peripheral: \(peripheral.identifier.uuidString)")
        log.debug("Advertisement Data: \(advertisementData.description)")
        log.debug("Name: \(peripheral.name)")
        
        self.peripherals.insert(peripheral)
        
        log.debug("Total scanned peripheral count: \(self.peripherals.count)")
        
        // Notify delegate of new peripheral found
        self.delegate?.peripheralFound?(self, peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    {
        log.error("Failed to connect to peripheral \(peripheral.identifier.uuidString). Error: \(error?.localizedDescription)")
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothDeviceManager : CBPeripheralDelegate
{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        if let services = peripheral.services
        {
            for service in services
            {
                peripheral.discoverCharacteristics(self.availableWriteCharacteristicCBUUIDs, for: service )
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        
        for characteristic in service.characteristics!
        {
            self.characteristicsForPeripheral[peripheral] = characteristic
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    {
        if (error != nil)
        {
            print(error!.localizedDescription)
        }
    }
}
