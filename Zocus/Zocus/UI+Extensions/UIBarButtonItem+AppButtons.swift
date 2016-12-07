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
        return UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    static func settingsButton(_ delegate: AnyObject, action: Selector) -> UIBarButtonItem
    {
        let icon = UIImage(named: "SettingsNavBar")!.withRenderingMode(.alwaysTemplate)
        let barButton = UIBarButtonItem(image: icon, style: .plain, target: delegate, action: action)
        barButton.tintColor = .white
        return barButton
    }

    static func textBarButton(_ text: String, delegate: AnyObject, action: Selector, color: UIColor = .black, font: UIFont = UIFont.systemFont(ofSize: 13.0)) -> UIBarButtonItem
    {
        let button = UIBarButtonItem(title: text, style: .plain, target: delegate, action: action)
        button.tintColor = color
        button.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        return button
    }
    
    static func activityIndicator(_ style: UIActivityIndicatorViewStyle = .white) -> UIBarButtonItem
    {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        return UIBarButtonItem(customView: activityIndicator)
    }
}
