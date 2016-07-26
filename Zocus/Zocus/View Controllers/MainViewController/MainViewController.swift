//
//  MainViewController.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit
import CocoaLumberjack
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
            self.currentLensLabel.font = .boldSystemFontOfSize(13.0)
        }
    }
    
    @IBOutlet weak var minLabel: UILabel! {
        didSet {
            self.minLabel.hidden = true
            self.minLabel.text = "Min".localized
            self.minLabel.textColor = .appGray()
            self.minLabel.font = .boldSystemFontOfSize(16.0)
        }
    }
    
    @IBOutlet weak var maxLabel: UILabel! {
        didSet {
            self.maxLabel.hidden = true
            self.maxLabel.text = "Max".localized
            self.maxLabel.textColor = .appGray()
            self.maxLabel.font = .systemFontOfSize(16.0)
        }
    }
    
    @IBOutlet weak var controlLabel: UILabel! {
        didSet {
            self.controlLabel.hidden = true
            self.controlLabel.text = "Control".localized
            self.controlLabel.textColor = .appGray()
            self.controlLabel.font = .boldSystemFontOfSize(16.0)
        }
    }
    
    @IBOutlet weak var calibrationSwitch: UISwitch! {
        didSet {
            self.calibrationSwitch.hidden = true
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
        DDLogInfo("Current lens: \(self.currentlyUsedLens)")
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
            
            self.zoomCalibrationRangeSlider.hidden = true
            self.zoomCalibrationRangeSlider.trackTintColor = .appRed()
            self.zoomCalibrationRangeSlider.thumbTintColor = .appGray()
            
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
            
            self.focusCalibrationRangeSlider.hidden = true
            self.focusCalibrationRangeSlider.trackTintColor = .appRed()
            self.focusCalibrationRangeSlider.thumbTintColor = .appGray()
            
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
            self.myLensesButton.layer.borderColor = UIColor.appGray().CGColor
            self.myLensesButton.layer.borderWidth = 1.0
            self.myLensesButton.layer.cornerRadius = 4.0
            self.myLensesButton.titleLabel?.textColor = .appGray()
            self.myLensesButton.setTitle("MyLenses".localized, forState: .Normal)
            self.myLensesButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13.0)
            self.myLensesButton.setTitleColor(.appGray(), forState: .Normal)
            self.myLensesButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    @IBOutlet weak var calibrateButton: UIButton! {
        didSet {
            self.calibrateButton.layer.borderColor = UIColor.appGray().CGColor
            self.calibrateButton.layer.borderWidth = 1.0
            self.calibrateButton.layer.cornerRadius = 4.0
            self.calibrateButton.titleLabel?.textColor = .appGray()
            self.calibrateButton.setTitle("Calibration.Calibrate".localized, forState: .Normal)
            self.calibrateButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13.0)
            self.calibrateButton.setTitleColor(.appGray(), forState: .Normal)
            self.calibrateButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    @IBOutlet weak var saveZoomButton: UIButton! {
        didSet {
            self.saveZoomButton.hidden = true
            self.saveZoomButton.enabled = true
            self.saveZoomButton.layer.borderColor = UIColor.appGray().CGColor
            self.saveZoomButton.layer.borderWidth = 1.0
            self.saveZoomButton.layer.cornerRadius = 4.0
            self.saveZoomButton.titleLabel?.textColor = .appGray()
            self.saveZoomButton.setTitle("Calibration.SaveZoom.Min".localized, forState: .Normal)
            self.saveZoomButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13.0)
            self.saveZoomButton.setTitleColor(.appGray(), forState: .Normal)
            self.saveZoomButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    @IBOutlet weak var saveFocusButton: UIButton! {
        didSet {
            self.saveFocusButton.hidden = true
            self.saveFocusButton.enabled = true
            self.saveFocusButton.layer.borderColor = UIColor.appGray().CGColor
            self.saveFocusButton.layer.borderWidth = 1.0
            self.saveFocusButton.layer.cornerRadius = 4.0
            self.saveFocusButton.titleLabel?.textColor = .appGray()
            self.saveFocusButton.setTitle("Calibration.SaveFocus.Min".localized, forState: .Normal)
            self.saveFocusButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13.0)
            self.saveFocusButton.setTitleColor(.appGray(), forState: .Normal)
            self.saveFocusButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    // Right
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    // MARK: - Bluetooth Manager
    private let bluetoothDeviceManagerInstance = BluetoothDeviceManager.sharedInstance
    private let activePeripheralsManagerInstance = ActivePeripheralsManager.sharedInstance
    
    private var searching : Bool = false
    private let ScanningTimeInSeconds = 20.0
    
    // MARK: - Data
    var realm : Realm!
    var lenses : Results<Lens> {
        get {
            return self.realm!.objects(Lens).sorted("name")
        }
    }
    
    var currentlyUsedLens : Lens {
        get {
            return self.realm!.objects(Lens)
                .filter("currently_used = %@", true)
                .sorted("name").first!
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
            DDLogInfo("Setting UIState: \(self.currentUIState.rawValue)")
            switch (self.currentUIState)
            {
            case .Active:
                 self.updateActiveSliders()
                 
                self.calibrateButton.setTitle("Calibration.Calibrate".localized, forState: .Normal)
                self.calibrateButton.setTitleColor(.appGray(), forState: .Normal)
                self.calibrateButton.layer.borderColor = UIColor.appGray().CGColor
                
                self.zoomSlider.hidden = false
                self.focusSlider.hidden = false
                self.zoomCalibrationRangeSlider.hidden = true
                self.focusCalibrationRangeSlider.hidden = true
                self.saveZoomButton.hidden = true
                self.saveFocusButton.hidden = true
                
                // Switch
                self.minLabel.hidden = true
                self.maxLabel.hidden = true
                self.controlLabel.hidden = true
                 
                self.calibrationSwitch.hidden = true
                self.calibrationSwitch.on = false
        
            case .Calibration:
                 self.updateCalibrationSliders()
                
                // Sliders
                self.calibrateButton.setTitle("Calibration.Exit".localized, forState: .Normal)
                self.calibrateButton.setTitleColor(.appRed(), forState: .Normal)
                self.calibrateButton.layer.borderColor = UIColor.appRed().CGColor
                
                self.zoomSlider.hidden = true
                self.focusSlider.hidden = true

                self.zoomCalibrationRangeSlider.hidden = false
                self.zoomCalibrationRangeSlider.alpha = 1.0
                self.zoomCalibrationRangeSlider.enabled = true
                self.saveZoomButton.hidden = false
                
                self.focusCalibrationRangeSlider.hidden = false
                self.focusCalibrationRangeSlider.alpha = 1.0
                self.focusCalibrationRangeSlider.enabled = true
                self.saveFocusButton.hidden = false
                
                // Switch
                self.minLabel.hidden = false
                self.maxLabel.hidden = false
                self.controlLabel.hidden = false
                self.calibrationSwitch.hidden = false
                self.calibrationSwitch.on = false
                
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
            DDLogInfo("Setting calibration value for \(self.currentCalibrationStep.rawValue) for \(self.currentUIState.rawValue) step")
            switch (self.currentCalibrationStep)
            {
            case .Min:
                self.minLabel.font = .boldSystemFontOfSize(16.0)
                self.maxLabel.font = .systemFontOfSize(16.0)
                
                self.saveZoomButton.setTitle("Calibration.SaveZoom.Min".localized, forState: .Normal)
                self.saveFocusButton.setTitle("Calibration.SaveFocus.Min".localized, forState: .Normal)
                
                self.zoomCalibrationRangeSlider.lowerThumbLayer.enabled = true
                self.focusCalibrationRangeSlider.lowerThumbLayer.enabled = true
                
                self.zoomCalibrationRangeSlider.upperThumbLayer.enabled = false
                self.focusCalibrationRangeSlider.upperThumbLayer.enabled = false
                
            case .Max:
                self.minLabel.font = .systemFontOfSize(16.0)
                self.maxLabel.font = .boldSystemFontOfSize(16.0)
                
                self.saveZoomButton.setTitle("Calibration.SaveZoom.Max".localized, forState: .Normal)
                self.saveFocusButton.setTitle("Calibration.SaveFocus.Max".localized, forState: .Normal)
                
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
        self.edgesForExtendedLayout = .All
        
        self.bluetoothDeviceManagerInstance.delegate = self
        self.bluetoothDeviceManagerInstance.reconnectIfDisconnected = true
        
        self.updateActiveSliders()
    }

    // MARK: - IB Actions

    // Use same slider action - different functions (zoom, focus) determined by value range
    @IBAction func sliderValueChanged(sender: UISlider)
    {
        let roundedValue = Int(sender.value)
        DDLogVerbose("Slider Value: \(roundedValue)")
        self.sendCommand("\(roundedValue)")
    }
    
    // Use same slider action - different functions (zoom, focus) determined by value range
    @IBAction func calibrationRangeSliderValueChanged(sender: RangeSlider)
    {
        let roundedValue : Int!
        switch (self.currentCalibrationStep)
        {
        case .Min:
            roundedValue = Int(sender.lowerValue)
        case .Max:
            roundedValue = Int(sender.upperValue)
        }
        DDLogVerbose("Calbration Slider Value: \(roundedValue)")
        self.sendCommand("\(roundedValue)")
    }
    
    @IBAction func sliderTappedAction(sender: UITapGestureRecognizer)
    {
        if let slider = sender.view as? UISlider
        {
            if slider.highlighted { return }
            
            let point = sender.locationInView(slider)
            let percentage = Float(point.x / CGRectGetWidth(slider.bounds))
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: true)
            
            self.sliderValueChanged(slider)
        }
    }
    
    @IBAction func refreshButtonPressed(sender: UIButton)
    {
        self.startScanning()
    }
    
    @IBAction func myLensesButtonPressed(sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier("LensesViewController") as? LensesViewController
        {
            vc.realm = self.realm
            vc.modalPresentationStyle = .Popover
            self.presentViewController(vc, animated: true, completion: nil)
        
            let popController = vc.popoverPresentationController
            popController?.permittedArrowDirections = .Up
            popController?.sourceView = self.view
            popController?.sourceRect = self.myLensesButton.frame
            
            let width = self.view.frame.width / 3.0
            let height = (CGFloat(self.lenses.count + 1) * 44.0) // (lens count + 1) * cell height
            vc.preferredContentSize = CGSizeMake(width, height)
            
            vc.delegate = self
        }
    }
    
    @IBAction func calibratePressed(sender: UIButton)
    {
        switch (self.currentUIState)
        {
        case .Active:
            self.currentUIState = .Calibration
        case .Calibration:
            self.currentUIState = .Active
        }
    }
    
    @IBAction func calibrationSwitchValueChanged(sender: UISwitch)
    {
        if (sender.on)
        {
            self.currentCalibrationStep = .Max
        }
        else
        {
            self.currentCalibrationStep = .Min
        }
    }
    
    @IBAction func saveZoomButtonPressed(sender: AnyObject)
    {
        do
        {
            DDLogInfo("Updating lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Zoom")
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
            DDLogError("Failed to update lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Zoom")
            
            self.showAlert("AddLens.SaveError".localized)
        }
    }
    
    @IBAction func saveFocusButtonPressed(sender: AnyObject)
    {
        do
        {
            DDLogInfo("Updating lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Focus")
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
            DDLogError("Failed to update lens '\(self.currentlyUsedLens.name)' calibration value for \(self.currentCalibrationStep) Focus")
            
            self.showAlert("AddLens.SaveError".localized)
        }
    }
    
    // MARK: - Bluetooth Methods
    
    private func startScanning()
    {
        // Scan again
        self.searching = true
        self.activityIndicator.startAnimating()
        self.refreshButton.hidden = true
        
        self.bluetoothDeviceManagerInstance.disconnectFromPeripherals(Array(self.activePeripheralsManagerInstance.scannedCBPeripherals))
        self.activePeripheralsManagerInstance.scannedPeripherals.removeAll() // clear cache
        self.bluetoothDeviceManagerInstance.searchForDevices(ScanningTimeInSeconds)
    }
    
    // Command Management
    func sendCommand(value: String)
    {
        for peripheral in self.activePeripheralsManagerInstance.scannedPeripherals
        {
            DDLogInfo("Sending \(value) to \(peripheral.cbPeripheral)")
            self.bluetoothDeviceManagerInstance.sendCommand(peripheral.cbPeripheral, command: value)
        }
    }
    
}

// MARK: - BluetoothDeviceManagerDelegate

extension MainViewController : BluetoothDeviceManagerDelegate
{
    // Helper function to find the used Service UUID for this peripheral
    private func findPeripheralsUsedServiceUUIDFromActiveList(advertisedServiceKeys: [CBUUID]) -> String
    {
        let activeServiceUUIDSet = Set(self.bluetoothDeviceManagerInstance.availableServiceCBUUIDs)
        let peripheralServiceUUIDSet = Set(advertisedServiceKeys)
        
        let matchingServiceUUIDSet = activeServiceUUIDSet.intersect(peripheralServiceUUIDSet)
        if (matchingServiceUUIDSet.count > 0)
        {
            let matchingServiceUUIDArray = Array(matchingServiceUUIDSet)
            return matchingServiceUUIDArray[0].UUIDString
        }
        else
        {
            return ""
        }
    }
    
    func peripheralFound(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber)
    {
        // Extract the device name and advertising data peripheral uses
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            advertisedServiceKeys = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
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
            DDLogError("Peripheral does not contain \(CBAdvertisementDataLocalNameKey) OR \(CBAdvertisementDataServiceUUIDsKey) in advertising data. Skipping peripheral.")
            return
        }
    }
    
    func bluetoothManagerFinishedScanning(bluetoothManager: BluetoothDeviceManager)
    {
        self.activityIndicator.stopAnimating()
        self.refreshButton.hidden = false
        self.bluetoothDeviceManagerInstance.connectToPeripherals(Array(self.activePeripheralsManagerInstance.scannedCBPeripherals))
    }
    
    // MARK: - Alerts
    func showAlert(message: String)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let actionOk = UIAlertAction(title: "Alert.OK".localized, style: .Default, handler: nil)
        alertController.addAction(actionOk)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}
