//
//  RangeSlider.swift
//  CustomSliderExample
//
//  Created by William Archimede on 04/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSliderTrackLayer: CALayer
{
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext)
    {
        guard let slider = rangeSlider else
        {
            return
        }
        
        // Clip
        let cornerRadius = bounds.height * slider.curvaceousness / 2.0
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        ctx.addPath(path.cgPath)
        
        // Fill the track
        ctx.setFillColor(slider.trackTintColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        // Fill the highlighted range
        ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
        let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
        let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
        let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
        ctx.fill(rect)
    }
}

class RangeSliderThumbLayer: CALayer
{
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var enabled: Bool = true
    
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext)
    {
        guard let slider = rangeSlider else
        {
            return
        }
        
        let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
        let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
        let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
        
        // Fill
        ctx.setFillColor(slider.thumbTintColor.cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()
        
        // Outline
        let strokeColor = UIColor.gray
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(0.5)
        ctx.addPath(thumbPath.cgPath)
        ctx.strokePath()
        
        if (self.highlighted)
        {
            ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}

@IBDesignable
class RangeSlider: UIControl
{
    @IBInspectable var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < self.maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            self.updateLayerFrames()
        }
    }
    
    @IBInspectable var maximumValue: Double = 1.0 {
        willSet(newValue) {
            assert(newValue > self.minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
        }
        didSet {
            self.updateLayerFrames()
        }
    }
    
    @IBInspectable var lowerValue: Double = 0.2 {
        didSet {
            if (self.lowerValue < self.minimumValue)
            {
                self.lowerValue = self.minimumValue
            }
            self.updateLayerFrames()
        }
    }
    
    @IBInspectable var upperValue: Double = 0.8 {
        didSet {
            if (self.upperValue > self.maximumValue)
            {
                self.upperValue = self.maximumValue
            }
            self.updateLayerFrames()
        }
    }
    
    var gapBetweenThumbs : Double {
        return Double(self.thumbWidth)*(self.maximumValue - self.minimumValue) / Double(bounds.width)
    }
    
    @IBInspectable var trackTintColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            self.trackLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable var trackHighlightTintColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            self.trackLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable var thumbTintColor = UIColor.white {
        didSet {
            self.lowerThumbLayer.setNeedsDisplay()
            self.upperThumbLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable var curvaceousness: CGFloat = 1.0 {
        didSet {
            if (self.curvaceousness < 0.0)
            {
                self.curvaceousness = 0.0
            }
            
            if (self.curvaceousness > 1.0)
            {
                self.curvaceousness = 1.0
            }
            
            self.trackLayer.setNeedsDisplay()
            self.lowerThumbLayer.setNeedsDisplay()
            self.upperThumbLayer.setNeedsDisplay()
        }
    }
    
    fileprivate var previouslocation = CGPoint()
    
    fileprivate let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer()
    let upperThumbLayer = RangeSliderThumbLayer()
    
    fileprivate var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    override var frame: CGRect {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.initializeLayers()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.initializeLayers()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.updateLayerFrames()
    }
    
    fileprivate func initializeLayers()
    {
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        self.trackLayer.rangeSlider = self
        self.trackLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(self.trackLayer)
        
        self.lowerThumbLayer.rangeSlider = self
        self.lowerThumbLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(self.lowerThumbLayer)
        
        self.upperThumbLayer.rangeSlider = self
        self.upperThumbLayer.contentsScale = UIScreen.main.scale
        self.layer.addSublayer(self.upperThumbLayer)
    }
    
    func updateLayerFrames()
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/3)
        self.trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(self.positionForValue(self.lowerValue))
        self.lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - self.thumbWidth/2.0, y: 0.0, width: self.thumbWidth, height: self.thumbWidth)
        self.lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(self.positionForValue(self.upperValue))
        self.upperThumbLayer.frame = CGRect(x: upperThumbCenter - self.thumbWidth/2.0, y: 0.0, width: self.thumbWidth, height: self.thumbWidth)
        self.upperThumbLayer.setNeedsDisplay()
        CATransaction.commit()
    }
    
    func positionForValue(_ value: Double) -> Double
    {
        return Double(bounds.width - self.thumbWidth) * (value - self.minimumValue) /
            (self.maximumValue - self.minimumValue) + Double(self.thumbWidth/2.0)
    }
    
    func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double
    {
        return min(max(value, lowerValue), upperValue)
    }
    
    // MARK: - Touches
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
    {
        self.previouslocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if (self.lowerThumbLayer.frame.contains(self.previouslocation))
        {
            self.lowerThumbLayer.highlighted = true
        }
        else if (self.upperThumbLayer.frame.contains(self.previouslocation))
        {
            self.upperThumbLayer.highlighted = true
        }
        
        return (self.lowerThumbLayer.highlighted || self.upperThumbLayer.highlighted)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
    {
        let location = touch.location(in: self)
        
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - self.previouslocation.x)
        let deltaValue = (self.maximumValue - self.minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        self.previouslocation = location
        
        // Update the values
        if (self.lowerThumbLayer.highlighted && self.lowerThumbLayer.enabled)
        {
            self.lowerValue = self.boundValue(self.lowerValue + deltaValue, toLowerValue: self.minimumValue, upperValue: self.upperValue - self.gapBetweenThumbs)
            sendActions(for: .valueChanged)
        }
        else if (self.upperThumbLayer.highlighted && self.upperThumbLayer.enabled)
        {
            self.upperValue = self.boundValue(self.upperValue + deltaValue, toLowerValue: self.lowerValue + self.gapBetweenThumbs, upperValue: self.maximumValue)
            sendActions(for: .valueChanged)
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?)
    {
        self.lowerThumbLayer.highlighted = false
        self.upperThumbLayer.highlighted = false
    }
}
