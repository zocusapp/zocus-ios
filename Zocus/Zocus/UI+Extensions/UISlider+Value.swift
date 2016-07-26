//
//  UISlider+Value.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit

extension UISlider
{
    var roundedValue : Int {
        get {
            return Int(self.value)
        }
    }
}