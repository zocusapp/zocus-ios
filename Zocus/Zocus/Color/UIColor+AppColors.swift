//
//  UIColor+AppColors.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import UIKit

extension UIColor
{
    static func defaultButtonColor() -> UIColor
    {
        return UIButton(type: UIButtonType.system).titleColor(for: UIControlState())!
    }
    
    static func appRed() -> UIColor
    {
        return UIColor(rgba: "#EA2E49")
    }
    
    static func appGray() -> UIColor
    {
        return UIColor(rgba: "#3B4B4E")
    }
    
    static func appBlue() -> UIColor
    {
        return UIColor(rgba: "#ACDBE5")
    }
}

