//
//  DDTTYLogger+XcodeColor.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import CocoaLumberjack

extension DDTTYLogger
{
    func setXcodeColors()
    {
        self.colorsEnabled = true
        self.setForegroundColor(UIColor.redColor(), backgroundColor: nil, forFlag: .Error)
        self.setForegroundColor(UIColor.orangeColor(), backgroundColor: nil, forFlag: .Warning)
        self.setForegroundColor(UIColor.blueColor(), backgroundColor: nil, forFlag: .Debug)
        self.setForegroundColor(UIColor.greenColor(), backgroundColor: nil, forFlag: .Info)
    }
}