//
//  MainViewController+LensesViewControllerDelegate.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import UIKit

// MARK: - LensesViewControllerDelegate
extension MainViewController : LensesViewControllerDelegate
{
    func addLensButtonPressed(_ viewController: LensesViewController)
    {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        let message = "AddLens.Message".localized
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // Name TextField
        alertController.addTextField { (textField) in
            textField.placeholder = "AddLens.NewLensNamePlaceholder".localized
            textField.autocapitalizationType = .words
            textField.addTarget(self, action: #selector(MainViewController.textChanged(_:)), for: .editingChanged)
        }
        
        // Buttons
        let save = UIAlertAction(title: "AddLens.Save".localized, style: .default) { (alert) in
            
            if let textfield = alertController.textFields?[0],
                let text = textfield.text
            {
                if (!text.isEmpty)
                {
                    self.realm.beginWrite()
                    let lens = Lens()
                    lens.name = text
                    
                    // Remove currently used marker from current lens
                    self.currentlyUsedLens.currently_used = false
                    
                    // Set new lens to currently used
                    lens.currently_used = true
                    
                    self.realm.add(lens)
    
                    do
                    {
                        try self.realm.commitWrite()
                        self.realm.refresh()
                        log.debug("Added lens '\(lens.name)'")
                        
                        self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
                    }
                    catch
                    {
                        log.error("Failed to add lens '\(lens.name)'")
                        
                        self.showAlert("AddLens.SaveError".localized)
                    }
                }
            }
        }
        save.isEnabled = false // start disabled until a name is given
        
        let cancel = UIAlertAction(title: "AddLens.Cancel".localized, style: .default, handler: nil)
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    // Observer changes on the text field, to disable/enable save button
    func textChanged(_ sender: UITextField)
    {
        var responder : UIResponder = sender
        while !(responder is UIAlertController)
        {
            responder = responder.next!
        }
        if let alert = responder as? UIAlertController
        {
            (alert.actions[0] as UIAlertAction).isEnabled = (sender.text != "")
        }
    }
    
    func lensSelected(_ viewController: LensesViewController, lens: Lens)
    {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        do
        {
            try self.realm.write {
                // Remove currently used marker from current lens
                self.currentlyUsedLens.currently_used = false
                
                // Set new lens to currently used
                lens.currently_used = true
                
                self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
            }
            self.realm.refresh()
        }
        catch
        {
            log.error("Failed to add lens '\(lens.name)'")
            
            self.showAlert("AddLens.SaveError".localized)
        }
    }
    
    func lensDeleted(_ viewController: LensesViewController, lens: Lens)
    {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        let message = "DeleteLens.Message".localized
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let delete = UIAlertAction(title: "DeleteLens.Delete".localized, style: .destructive) { (alert) in
            do
            {
                log.info("Deleting lens '\(lens.name)'")
                try self.realm.write {
                    // Check if deleted lens is currently in use
                    if (lens.currently_used)
                    {
                        // Find next in list and assign current, unless there are no more left
                        // In case of 0, a default will be created and set
                        var allLenses = Array(self.lenses)
                        if let found = allLenses.index(where: { $0.name == lens.name })
                        {
                            allLenses.remove(at: found)
                        }
                        
                        if (allLenses.count > 0)
                        {
                            if let first = allLenses.first
                            {
                                first.currently_used = true
                            }
                        }
                    }
                    self.realm.delete(lens)
                }
                self.realm.refresh()
            }
            catch
            {
                log.error("Failed to delete lens '\(lens.name)'")
            }
            
            // Create default realm if necessary
            checkAndCreateDefaultLens()
            self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
            self.updateActiveSliders()
        }
        let cancel = UIAlertAction(title: "DeleteLens.Cancel".localized, style: .default, handler: nil)
        
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func lensEdited(_ viewController: LensesViewController, lens: Lens)
    {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        let message = "EditLens.Message".localized
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // Name TextField
        alertController.addTextField { (textField) in
            textField.placeholder = "AddLens.NewLensNamePlaceholder".localized
            textField.text = lens.name
            textField.autocapitalizationType = .words
            textField.addTarget(self, action: #selector(MainViewController.textChanged(_:)), for: .editingChanged)
        }
        
        // Buttons
        let save = UIAlertAction(title: "AddLens.Save".localized, style: .default) { (alert) in
            
            if let textfield = alertController.textFields?[0],
                let text = textfield.text
            {
                if (!text.isEmpty)
                {
                    self.realm.beginWrite()
                    lens.name = text
                    
                    do
                    {
                        try self.realm.commitWrite()
                        self.realm.refresh()
                        log.debug("Edited lens name to '\(lens.name)'")
                        self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
                    }
                    catch
                    {
                        log.error("Failed to edit lens name to '\(text)'")
                        
                        self.showAlert("AddLens.SaveError".localized)
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "AddLens.Cancel".localized, style: .default, handler: nil)
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        })
    }
}
