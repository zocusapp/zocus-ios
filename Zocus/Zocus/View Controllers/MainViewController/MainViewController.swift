//
//  MainViewController.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit
import CoreBluetooth
import RealmSwift

private let CalibrationMaxZoom: Double = 100
private let CalibrationMinZoom: Double = 1
private let CalibrationZoomStartLower: Double = 45
private let CalibrationZoomStartUpper: Double = 55

private let CalibrationMaxFocus: Double = 0
private let CalibrationMinFocus: Double = -100
private let CalibrationFocusStartLower: Double = -55
private let CalibrationFocusStartUpper: Double = -45

class MainViewController: UIViewController
{
    // MARK: - UI Outlets
    
    @IBOutlet weak var zoomLabel: UILabel! {
        didSet {
            self.zoomLabel.text = "Zoom".localized
            self.zoomLabel.textColor = .appGray()
        }
    }
    
    @IBOutlet weak var focusLabel: UILabel! {
        didSet {
            self.focusLabel.text = "Focus".localized
            self.focusLabel.textColor = .appGray()
        }
    }
    
    @IBOutlet weak var currentLensLabel: UILabel! {
        didSet {
            self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
            self.currentLensLabel.textColor = .appGray()
            self.currentLensLabel.font = .boldSystemFont(ofSize: 13.0)
        }
    }
    
    @IBOutlet weak var minLabel: UILabel! {
        didSet {
            self.minLabel.isHidden = true
            self.minLabel.text = "Min".localized
            self.minLabel.textColor = .appGray()
            self.minLabel.font = .boldSystemFont(ofSize: 16.0)
        }
    }
    
    @IBOutlet weak var maxLabel: UILabel! {
        didSet {
            self.maxLabel.isHidden = true
            self.maxLabel.text = "Max".localized
            self.maxLabel.textColor = .appGray()
            self.maxLabel.font = .systemFont(ofSize: 16.0)
        }
    }
    
    @IBOutlet weak var controlLabel: UILabel! {
        didSet {
            self.controlLabel.isHidden = true
            self.controlLabel.text = "Control".localized
            self.controlLabel.textColor = .appGray()
            self.controlLabel.font = .boldSystemFont(ofSize: 16.0)
        }
    }
    
    @IBOutlet weak var calibrationSwitch: UISwitch! {
        didSet {
            self.calibrationSwitch.isHidden = true
            self.calibrationSwitch.onTintColor = .appRed()
            self.calibrationSwitch.tintColor = .appRed()
            self.calibrationSwitch.thumbTintColor = .appGray()
        }
    }
    
    // Sliders
    
    @IBOutlet weak var zoomSlider: UISlider! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.sliderTappedAction(_:)))
            self.zoomSlider.addGestureRecognizer(tapGestureRecognizer)
            self.zoomSlider.minimumTrackTintColor = .appRed()
            self.zoomSlider.maximumTrackTintColor = .appGray()
        }
    }
    
    @IBOutlet weak var focusSlider: UISlider!  {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.sliderTappedAction(_:)))
            self.focusSlider.addGestureRecognizer(tapGestureRecognizer)
            self.focusSlider.minimumTrackTintColor = .appRed()
            self.focusSlider.maximumTrackTintColor = .appGray()
        }
    }
    
    func updateActiveSliders()
    {
        log.info("Current lens: \(self.currentlyUsedLens)")
        let zoomRange = Float((self.currentlyUsedLens.max_zoom - self.currentlyUsedLens.min_zoom) / 2.0)
        let zoomMidPoint = Float(self.currentlyUsedLens.min_zoom) + zoomRange
        self.zoomSlider.value = zoomMidPoint
        self.zoomSlider.minimumValue = Float(self.currentlyUsedLens.min_zoom)
        self.zoomSlider.maximumValue = Float(self.currentlyUsedLens.max_zoom)
        
        let focusRange = Float((self.currentlyUsedLens.max_focus - self.currentlyUsedLens.min_focus) / 2.0)
        let focusMidPoint = Float(self.currentlyUsedLens.min_focus) + focusRange
        self.focusSlider.value = focusMidPoint
        self.focusSlider.minimumValue = Float(self.currentlyUsedLens.min_focus)
        self.focusSlider.maximumValue = Float(self.currentlyUsedLens.max_focus)
    }
    
    // Calibration Sliders
    
    @IBOutlet weak var zoomCalibrationRangeSlider: RangeSlider! {
        didSet {
            self.zoomCalibrationRangeSlider.minimumValue = CalibrationMinZoom
            self.zoomCalibrationRangeSlider.maximumValue = CalibrationMaxZoom
            
            self.zoomCalibrationRangeSlider.lowerValue = CalibrationZoomStartLower
            self.zoomCalibrationRangeSlider.upperValue = CalibrationZoomStartUpper
            
            self.zoomCalibrationRangeSlider.isHidden = true
            self.zoomCalibrationRangeSlider.trackTintColor = .appRed()
            self.zoomCalibrationRangeSlider.thumbTintColor = .appGray()
            self.zoomCalibrationRangeSlider.trackHighlightTintColor = .appGray()
            
            self.zoomCalibrationRangeSlider.lowerThumbLayer.enabled = true            
            self.zoomCalibrationRangeSlider.upperThumbLayer.enabled = false
        }
    }
    
    @IBOutlet weak var focusCalibrationRangeSlider: RangeSlider! {
        didSet {
            self.focusCalibrationRangeSlider.minimumValue = CalibrationMinFocus
            self.focusCalibrationRangeSlider.maximumValue = CalibrationMaxFocus
            
            self.focusCalibrationRangeSlider.lowerValue = CalibrationFocusStartLower
            self.focusCalibrationRangeSlider.upperValue = CalibrationFocusStartUpper
            
            self.focusCalibrationRangeSlider.isHidden = true
            self.focusCalibrationRangeSlider.trackTintColor = .appRed()
            self.focusCalibrationRangeSlider.thumbTintColor = .appGray()
            self.focusCalibrationRangeSlider.trackHighlightTintColor = .appGray()
            
            self.focusCalibrationRangeSlider.lowerThumbLayer.enabled = true
            self.focusCalibrationRangeSlider.upperThumbLayer.enabled = false
        }
    }
    
    func updateCalibrationSliders()
    {
        // TODO
    }
    
    // Buttons
    
    @IBOutlet weak var myLensesButton: UIButton! {
        didSet {
            self.myLensesButton.layer.borderColor = UIColor.appGray().cgColor
            self.myLensesButton.layer.borderWidth = 1.0
            self.myLensesButton.layer.cornerRadius = 4.0
            self.myLensesButton.titleLabel?.textColor = .appGray()
            self.myLensesButton.setTitle("MyLenses".localized, for: UIControlState())
            self.myLensesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
            self.myLensesButton.setTitleColor(.appGray(), for: UIControlState())
            self.myLensesButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    @IBOutlet weak var calibrateButton: UIButton! {
        didSet {
            self.calibrateButton.layer.borderColor = UIColor.appGray().cgColor
            self.calibrateButton.layer.borderWidth = 1.0
            self.calibrateButton.layer.cornerRadius = 4.0
            self.calibrateButton.titleLabel?.textColor = .appGray()
            self.calibrateButton.setTitle("Calibration.Calibrate".localized, for: UIControlState())
            self.calibrateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
            self.calibrateButton.setTitleColor(.appGray(), for: UIControlState())
            self.calibrateButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    @IBOutlet weak var saveZoomButton: UIButton! {
        didSet {
            self.saveZoomButton.isHidden = true
            self.saveZoomButton.isEnabled = true
            self.saveZoomButton.layer.borderColor = UIColor.appGray().cgColor
            self.saveZoomButton.layer.borderWidth = 1.0
            self.saveZoomButton.layer.cornerRadius = 4.0
            self.saveZoomButton.titleLabel?.textColor = .appGray()
            self.saveZoomButton.setTitle("Calibration.SaveZoom.Min".localized, for: UIControlState())
            self.saveZoomButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
            self.saveZoomButton.setTitleColor(.appGray(), for: UIControlState())
            self.saveZoomButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    @IBOutlet weak var saveFocusButton: UIButton! {
        didSet {
            self.saveFocusButton.isHidden = true
            self.saveFocusButton.isEnabled = true
            self.saveFocusButton.layer.borderColor = UIColor.appGray().cgColor
            self.saveFocusButton.layer.borderWidth = 1.0
            self.saveFocusButton.layer.cornerRadius = 4.0
            self.saveFocusButton.titleLabel?.textColor = .appGray()
            self.saveFocusButton.setTitle("Calibration.SaveFocus.Min".localized, for: UIControlState())
            self.saveFocusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13.0)
            self.saveFocusButton.setTitleColor(.appGray(), for: UIControlState())
            self.saveFocusButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    // Right
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    // MARK: - Bluetooth Manager
    fileprivate let bluetoothDeviceManagerInstance = BluetoothDeviceManager.sharedInstance
    fileprivate let activePeripheralsManagerInstance = ActivePeripheralsManager.sharedInstance
    
    fileprivate var searching : Bool = false
    fileprivate let ScanningTimeInSeconds = 20.0
    
    // MARK: - Data
    var realm : Realm!
    var lenses : Results<Lens> {
        get {
            return self.realm!.objects(Lens.self).sorted(byProperty: "name")
        }
    }
    
    var currentlyUsedLens : Lens {
        get {
            return self.realm!.objects(Lens.self)
                .filter("currently_used = %@", true)
                .sorted(byProperty: "name").first!
        }
    }
    
    enum UIState : String
    {
        case Active
        case Calibration
        
        static let allStates : [UIState] = [.Active, .Calibration]
    }
    
    var currentUIState : UIState = .Active {
        didSet {
            log.info("Setting UIState: \(self.currentUIState.rawValue)")
            switch (self.currentUIState)
            {
            case .Active:
                 self.updateActiveSliders()
                 
                self.calibrateButton.setTitle("Calibration.Calibrate".localized, for: UIControlState())
                self.calibrateButton.setTitleColor(.appGray(), for: UIControlState())
                self.calibrateButton.layer.borderColor = UIColor.appGray().cgColor
                
                self.zoomSlider.isHidden = false
                self.focusSlider.isHidden = false
                self.zoomCalibrationRangeSlider.isHidden = true
                self.focusCalibrationRangeSlider.isHidden = true
                self.saveZoomButton.isHidden = true
                self.saveFocusButton.isHidden = true
                
                // Switch
                self.minLabel.isHidden = true
                self.maxLabel.isHidden = true
                self.controlLabel.isHidden = true
                 
                self.calibrationSwitch.isHidden = true
                self.calibrationSwitch.isOn = false
        
            case .Calibration:
                 self.updateCalibrationSliders()
                
                // Sliders
                self.calibrateButton.setTitle("Calibration.Exit".localized, for: UIControlState())
                self.calibrateButton.setTitleColor(.appRed(), for: UIControlState())
                self.calibrateButton.layer.borderColor = UIColor.appRed().cgColor
                
                self.zoomSlider.isHidden = true
                self.focusSlider.isHidden = true

                self.zoomCalibrationRangeSlider.isHidden = false
                self.zoomCalibrationRangeSlider.alpha = 1.0
                self.zoomCalibrationRangeSlider.isEnabled = true
                self.saveZoomButton.isHidden = false
                
                self.focusCalibrationRangeSlider.isHidden = false
                self.focusCalibrationRangeSlider.alpha = 1.0
                self.focusCalibrationRangeSlider.isEnabled = true
                self.saveFocusButton.isHidden = false
                
                // Switch
                self.minLabel.isHidden = false
                self.maxLabel.isHidden = false
                self.controlLabel.isHidden = false
                self.calibrationSwitch.isHidden = false
                self.calibrationSwitch.isOn = false
                
                // Show calibration explanation
                self.showAlert("Calibration.Explanation".localized)
            }
        }
    }
    
    enum CalibrationStep : String
    {
        case Min
        case Max
        
        static let allSteps : [CalibrationStep] = [.Min, .Max]
    }
    
    var currentCalibrationStep : CalibrationStep = .Min {
        didSet {
            log.info("Setting calibration value for \(self.currentCalibrationStep.rawValue) for \(self.currentUIState.rawValue) step")
            switch (self.currentCalibrationStep)
            {
            case .Min:
                self.minLabel.font = .boldSystemFont(ofSize: 16.0)
                self.maxLabel.font = .systemFont(ofSize: 16.0)
                
                self.saveZoomButton.setTitle("Calibration.SaveZoom.Min".localized, for: UIControlState())
                self.saveFocusButton.setTitle("Calibration.SaveFocus.Min".localized, for: UIControlState())
                
                self.zoomCalibrationRangeSlider.lowerThumbLayer.enabled = true
                self.focusCalibrationRangeSlider.lowerThumbLayer.enabled = true
                
                self.zoomCalibrationRangeSlider.upperThumbLayer.enabled = false
                self.focusCalibrationRangeSlider.upperThumbLayer.enabled = false
                
            case .Max:
                self.minLabel.font = .systemFont(ofSize: 16.0)
                self.maxLabel.font = .boldSystemFont(ofSize: 16.0)
                
                self.saveZoomButton.setTitle("Calibration.SaveZoom.Max".localized, for: UIControlState())
                self.saveFocusButton.setTitle("Calibration.SaveFocus.Max".localized, for: UIControlState())
                
                self.zoomCalibrationRangeSlider.lowerThumbLayer.enabled = false
                self.focusCalibrationRangeSlider.lowerThumbLayer.enabled = false
                
                self.zoomCalibrationRangeSlider.upperThumbLayer.enabled = true
                self.focusCalibrationRangeSlider.upperThumbLayer.enabled = true
            }
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = .appBlue()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Compensate for hidden nav bar by extending the scroll view
        self.edgesForExtendedLayout = .all
        
        self.bluetoothDeviceManagerInstance.delegate = self
        self.bluetoothDeviceManagerInstance.reconnectIfDisconnected = true
        
        self.updateActiveSliders()
    }

    // MARK: - IB Actions

    // Use same slider action - different functions (zoom, focus) determined by value range
    @IBAction func sliderValueChanged(_ sender: UISlider)
    {
        let roundedValue = Int(sender.value)
        log.verbose("Slider Value: \(roundedValue)")
        self.sendCommand("\(roundedValue)")
    }
    
    // Use same slider action - different functions (zoom, focus) determined by value range
    @IBAction func calibrationRangeSliderValueChanged(_ sender: RangeSlider)
    {
        let roundedValue : Int!
        switch (self.currentCalibrationStep)
        {
        case .Min:
            roundedValue = Int(sender.lowerValue)
        case .Max:
            roundedValue = Int(sender.upperValue)
        }
        log.verbose("Calbration Slider Value: \(roundedValue)")
        self.sendCommand("\(roundedValue)")
    }
    
    @IBAction func sliderTappedAction(_ sender: UITapGestureRecognizer)
    {
        if let slider = sender.view as? UISlider
        {
            if slider.isHighlighted { return }
            
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: true)
            
            self.sliderValueChanged(slider)
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton)
    {
        self.startScanning()
    }
    
    @IBAction func myLensesButtonPressed(_ sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "LensesViewController") as? LensesViewController
        {
            vc.realm = self.realm
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true, completion: nil)
        
            let popController = vc.popoverPresentationController
            popController?.permittedArrowDirections = .up
            popController?.sourceView = self.view
            popController?.sourceRect = self.myLensesButton.frame
            
            let width = self.view.frame.width / 3.0
            let height = (CGFloat(self.lenses.count + 1) * 44.0) // (lens count + 1) * cell height
            vc.preferredContentSize = CGSize(width: width, height: height)
            
            vc.delegate = self
        }
    }
    
    @IBAction func calibratePressed(_ sender: UIButton)
    {
        switch (self.currentUIState)
        {
        case .Active:
            self.currentUIState = .Calibration
        case .Calibration:
            self.currentUIState = .Active
        }
    }
    
    @IBAction func calibrationSwitchValueChanged(_ sender: UISwitch)
    {
        if (sender.isOn)
        {
            self.currentCalibrationStep = .Max
        }
        else
        {
            self.currentCalibrationStep = .Min
        }
    }
    
    @IBAction func saveZoomButtonPressed(_ sender: AnyObject)
    {
        do
        {
            log.info("Updating lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Zoom")
            try self.realm.write {
                switch (self.currentCalibrationStep)
                {
                case .Min:
                    self.currentlyUsedLens.min_zoom = self.zoomCalibrationRangeSlider.lowerValue
                case .Max:
                    self.currentlyUsedLens.max_zoom = self.zoomCalibrationRangeSlider.upperValue
                }
            }
            self.realm.refresh()
        }
        catch
        {
            log.error("Failed to update lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Zoom")
            
            self.showAlert("AddLens.SaveError".localized)
        }
    }
    
    @IBAction func saveFocusButtonPressed(_ sender: AnyObject)
    {
        do
        {
            log.info("Updating lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Focus")
            try self.realm.write {
                switch (self.currentCalibrationStep)
                {
                case .Min:
                    self.currentlyUsedLens.min_focus = self.focusCalibrationRangeSlider.lowerValue
                case .Max:
                    self.currentlyUsedLens.max_focus = self.focusCalibrationRangeSlider.upperValue
                }
            }
            self.realm.refresh()
        }
        catch
        {
            log.error("Failed to update lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Focus")
            
            self.showAlert("AddLens.SaveError".localized)
        }
    }
    
    // MARK: - Bluetooth Methods
    
    fileprivate func startScanning()
    {
        // Scan again
        self.searching = true
        self.activityIndicator.startAnimating()
        self.refreshButton.isHidden = true
        
        self.bluetoothDeviceManagerInstance.disconnectFromPeripherals(Array(self.activePeripheralsManagerInstance.scannedCBPeripherals))
        self.activePeripheralsManagerInstance.scannedPeripherals.removeAll() // clear cache
        self.bluetoothDeviceManagerInstance.searchForDevices(ScanningTimeInSeconds)
    }
    
    // Command Management
    func sendCommand(_ value: String)
    {
        for peripheral in self.activePeripheralsManagerInstance.scannedPeripherals
        {
            log.info("Sending \(value) to \(peripheral.cbPeripheral)")
            self.bluetoothDeviceManagerInstance.sendCommand(peripheral.cbPeripheral, command: value)
        }
    }
    
}

// MARK: - BluetoothDeviceManagerDelegate

extension MainViewController : BluetoothDeviceManagerDelegate
{
    // Helper function to find the used Service UUID for this peripheral
    fileprivate func findPeripheralsUsedServiceUUIDFromActiveList(_ advertisedServiceKeys: [CBUUID]) -> String
    {
        let activeServiceUUIDSet = Set(self.bluetoothDeviceManagerInstance.availableServiceCBUUIDs)
        let peripheralServiceUUIDSet = Set(advertisedServiceKeys)
        
        let matchingServiceUUIDSet = activeServiceUUIDSet.intersection(peripheralServiceUUIDSet)
        if (matchingServiceUUIDSet.count > 0)
        {
            let matchingServiceUUIDArray = Array(matchingServiceUUIDSet)
            return matchingServiceUUIDArray[0].uuidString
        }
        else
        {
            return ""
        }
    }
    
    func peripheralFound(_ bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, advertisementData: [AnyHashable: Any]!, RSSI: NSNumber)
    {
        // Extract the device name and advertising data peripheral uses
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            let advertisedServiceKeys = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
        {
            // Get Service UUID peripheral uses
            let usedServiceUUID = self.findPeripheralsUsedServiceUUIDFromActiveList(advertisedServiceKeys)
            if (usedServiceUUID != "")
            {
                let objPeripheral = Peripheral(name: name, serviceUUID: usedServiceUUID)
                self.activePeripheralsManagerInstance.scannedPeripherals.insert(ActivePeripheral(cb: peripheral, obj: objPeripheral))
            }
            else
            {
                return
            }
        }
        else
        {
            log.error("Peripheral does not contain \(CBAdvertisementDataLocalNameKey) OR \(CBAdvertisementDataServiceUUIDsKey) in advertising data. Skipping peripheral.")
            return
        }
    }
    
    func bluetoothManagerFinishedScanning(_ bluetoothManager: BluetoothDeviceManager)
    {
        self.activityIndicator.stopAnimating()
        self.refreshButton.isHidden = false
        self.bluetoothDeviceManagerInstance.connectToPeripherals(Array(self.activePeripheralsManagerInstance.scannedCBPeripherals))
    }
    
    // MARK: - Alerts
    func showAlert(_ message: String)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Alert.OK".localized, style: .default, handler: nil)
        alertController.addAction(actionOk)
        DispatchQueue.main.async(execute: { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        })
    }
}
