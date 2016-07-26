//
//  Realm+Init.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

func deleteAllLenses()
{
    let realm = try! Realm()
    DDLogInfo("Deleting lenses")
    do
    {
        try realm.write {
            realm.objects(Lens).forEach({ (d) in
                realm.delete(d)
            })
        }
        
    }
    catch
    {
        DDLogError("Failed to delete realm")
    }
}

func checkAndCreateDefaultLens()
{
    // Setup Data Model - Realm
    let realm = try! Realm()
    
    // Create default lens if no lenses exist
    let lenses = realm.objects(Lens)
    if (lenses.count == 0)
    {
        DDLogDebug("Adding Default Lens")
        
        realm.beginWrite()
        let defaultLens = Lens()
        defaultLens.name = "Default"
        defaultLens.currently_used = true
        
        realm.add(defaultLens)
        
        do
        {
            try realm.commitWrite()
            DDLogDebug("Added Default Lens")
        }
        catch
        {
            DDLogError("Failed to add Default lens")
        }
    }
}