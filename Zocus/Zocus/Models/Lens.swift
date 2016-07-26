//
//  Lens.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import RealmSwift

class Lens: Object
{
    dynamic var name = ""

    // Zoom
    dynamic var min_zoom = 1.0
    dynamic var max_zoom = 100.0
    
    // Focus
    dynamic var min_focus = -(100.0)
    dynamic var max_focus = 0.0
    
    dynamic var currently_used = false
}
