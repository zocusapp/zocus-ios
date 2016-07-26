//
//  String+Localization.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation

extension String
{
    var localized : String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
}