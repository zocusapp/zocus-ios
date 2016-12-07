//
//  UINavigationController+UI.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController
{
    // Hide thin line beneath navbar
    func hideShadow()
    {
        self.navigationBar.setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        self.navigationBar.shadowImage = UIImage()
    }
}
