//
//  LensesViewController+UITableViewDelegate.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit
import CocoaLumberjack

extension LensesViewController : UITableViewDelegate
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let lens = self.lenses[indexPath.row]
        DDLogInfo("Lens selected \(lens.name)")
        self.delegate?.lensSelected(self, lens: lens)
    }
}
