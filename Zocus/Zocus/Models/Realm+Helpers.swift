//
//  Realm+Init.swift
//  Zocus
//
//  Created by Akram Hussein on 26/07/2016.
//  Copyright © 2016 Akram Hussein. All rights reserved.
//

import Foundation
import RealmSwift

func deleteAllLenses()
{
    let realm = try! Realm()
    log.info("Deleting lenses")
    do
    {
        try realm.write {
            realm.objects(Lens.self).forEach({ (d) in
                realm.delete(d)
            })
        }
        
    }
    catch
    {
        log.error("Failed to delete realm")
    }
}

func checkAndCreateDefaultLens()
{
    // Setup Data Model - Realm
    let realm = try! Realm()
    
    // Create default lens if no lenses exist
    let lenses = realm.objects(Lens.self)
    if (lenses.count == 0)
    {
        log.debug("Adding Default Lens")
        
        realm.beginWrite()
        let defaultLens = Lens()
        defaultLens.name = "Default"
        defaultLens.currently_used = true
        
        realm.add(defaultLens)
        
        do
        {
            try realm.commitWrite()
            log.debug("Added Default Lens")
        }
        catch
        {
            log.error("Failed to add Default lens")
        }
    }
}
