//
//  LensesViewController+UITableViewDelegate.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import UIKit

extension LensesViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let lens = self.lenses[indexPath.row]
        log.info("Lens selected \(lens.name)")
        self.delegate?.lensSelected(self, lens: lens)
    }
}
