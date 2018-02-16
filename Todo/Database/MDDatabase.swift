//
//  MDDatabase.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MDDatabase: NSObject {
    
    static let shareInstance = MDDatabase()
    
    func saveModels<T>(models: [T], update: Bool) where T: Object {
        guard update, let primaryKey = T.primaryKey() else {
            importModels(models: models)
            return
        }
        
        let realm = try! Realm()
        let importIDs = models.flatMap{$0.value(forKeyPath: primaryKey)}
        //fetch all models
        let predicate = NSPredicate(format: "!(\(primaryKey) IN %@)", argumentArray: [importIDs])
        let deleteModels = realm.objects(T.self).filter(predicate)
        print("\(T.description()) - Import \(importIDs.count) and delete: \(deleteModels.count)")
        do {
            try realm.write {
                realm.add(models, update: true)
                realm.delete(deleteModels)
            }
        } catch {
            print(error.getString)
        }
        
    }
    
    func importModels<T>(models: [T]) where T: Object {
        let realm = try! Realm()
        try! realm.write {
            realm.add(models)
        }
    }
    
}

