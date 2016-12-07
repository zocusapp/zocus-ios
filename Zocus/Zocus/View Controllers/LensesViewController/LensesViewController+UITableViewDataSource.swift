//
//  LensesViewController+UITableViewDataSource.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import UIKit

extension LensesViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.LensCellIdentifier, for: indexPath)
        let lens = self.lenses[indexPath.row]
        cell.textLabel?.text = "\(lens.name)"
        cell.textLabel?.textColor = .appGray()
        
        // Currently used lens?
        if (lens.currently_used)
        {            
            let image = UIImage(named: "CheckMark")
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 28.0, height: 28.0)
            cell.accessoryView = imageView
        }
        else
        {
            cell.accessoryView = nil
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.lenses.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let editAction = UITableViewRowAction(style: .default, title: "AddLens.EditRowButton".localized, handler:{action, indexPath in
            let lens = self.lenses[indexPath.row]
            self.delegate?.lensEdited(self, lens: lens)
        })
        editAction.backgroundColor = .appGray()
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive,
                                                title: "AddLens.DeleteRowButton".localized,
                                                handler:{ action, indexPath in
            let lens = self.lenses[indexPath.row]
            self.delegate?.lensDeleted(self, lens: lens)
        })
        
        return [deleteAction, editAction]
    }
}
