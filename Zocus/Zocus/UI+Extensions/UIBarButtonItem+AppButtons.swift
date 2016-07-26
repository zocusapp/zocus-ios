//
//  UIBarButtonItem+AppButtons.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem
{
    static func emptyBackButton() -> UIBarButtonItem
    {
        return UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    static func settingsButton(delegate: AnyObject, action: Selector) -> UIBarButtonItem
    {
        let icon = UIImage(named: "SettingsNavBar")!.imageWithRenderingMode(.AlwaysTemplate)
        let barButton = UIBarButtonItem(image: icon, style: .Plain, target: delegate, action: action)
        barButton.tintColor = .whiteColor()
        return barButton
    }

    static func textBarButton(text: String, delegate: AnyObject, action: Selector, color: UIColor = .blackColor(), font: UIFont = UIFont.systemFontOfSize(13.0)) -> UIBarButtonItem
    {
        let button = UIBarButtonItem(title: text, style: .Plain, target: delegate, action: action)
        button.tintColor = color
        button.setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
        return button
    }
    
    static func activityIndicator(style: UIActivityIndicatorViewStyle = .White) -> UIBarButtonItem
    {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        return UIBarButtonItem(customView: activityIndicator)
    }
}