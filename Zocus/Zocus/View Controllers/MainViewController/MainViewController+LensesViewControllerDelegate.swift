//
//  MainViewController+LensesViewControllerDelegate.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

// MARK: - LensesViewControllerDelegate
extension MainViewController : LensesViewControllerDelegate
{
    func addLensButtonPressed(viewController: LensesViewController)
    {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        let message = "AddLens.Message".localized
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        // Name TextField
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "AddLens.NewLensNamePlaceholder".localized
            textField.autocapitalizationType = .Words
            textField.addTarget(self, action: #selector(MainViewController.textChanged(_:)), forControlEvents: .EditingChanged)
        }
        
        // Buttons
        let save = UIAlertAction(title: "AddLens.Save".localized, style: .Default) { (alert) in
            
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
                        DDLogDebug("Added lens '\(lens.name)'")
                        
                        self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
                    }
                    catch
                    {
                        DDLogError("Failed to add lens '\(lens.name)'")
                        
                        self.showAlert("AddLens.SaveError".localized)
                    }
                }
            }
        }
        save.enabled = false // start disabled until a name is given
        
        let cancel = UIAlertAction(title: "AddLens.Cancel".localized, style: .Default, handler: nil)
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    // Observer changes on the text field, to disable/enable save button
    func textChanged(sender: UITextField)
    {
        var responder : UIResponder = sender
        while !(responder is UIAlertController)
        {
            responder = responder.nextResponder()!
        }
        if let alert = responder as? UIAlertController
        {
            (alert.actions[0] as UIAlertAction).enabled = (sender.text != "")
        }
    }
    
    func lensSelected(viewController: LensesViewController, lens: Lens)
    {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        
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
            DDLogError("Failed to add lens '\(lens.name)'")
            
            self.showAlert("AddLens.SaveError".localized)
        }
    }
    
    func lensDeleted(viewController: LensesViewController, lens: Lens)
    {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        let message = "DeleteLens.Message".localized
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let delete = UIAlertAction(title: "DeleteLens.Delete".localized, style: .Destructive) { (alert) in
            do
            {
                DDLogInfo("Deleting lens '\(lens.name)'")
                try self.realm.write {
                    // Check if deleted lens is currently in use
                    if (lens.currently_used)
                    {
                        // Find next in list and assign current, unless there are no more left
                        // In case of 0, a default will be created and set
                        var allLenses = Array(self.lenses)
                        if let found = allLenses.indexOf({ $0.name == lens.name })
                        {
                            allLenses.removeAtIndex(found)
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
                DDLogError("Failed to delete lens '\(lens.name)'")
            }
            
            // Create default realm if necessary
            checkAndCreateDefaultLens()
            self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
            self.updateActiveSliders()
        }
        let cancel = UIAlertAction(title: "DeleteLens.Cancel".localized, style: .Default, handler: nil)
        
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func lensEdited(viewController: LensesViewController, lens: Lens)
    {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        let message = "EditLens.Message".localized
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        
        // Name TextField
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "AddLens.NewLensNamePlaceholder".localized
            textField.text = lens.name
            textField.autocapitalizationType = .Words
            textField.addTarget(self, action: #selector(MainViewController.textChanged(_:)), forControlEvents: .EditingChanged)
        }
        
        // Buttons
        let save = UIAlertAction(title: "AddLens.Save".localized, style: .Default) { (alert) in
            
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
                        DDLogDebug("Edited lens name to '\(lens.name)'")
                        self.currentLensLabel.text = "\(self.currentlyUsedLens.name) Lens"
                    }
                    catch
                    {
                        DDLogError("Failed to edit lens name to '\(text)'")
                        
                        self.showAlert("AddLens.SaveError".localized)
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "AddLens.Cancel".localized, style: .Default, handler: nil)
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}