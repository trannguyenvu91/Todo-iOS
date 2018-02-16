//
//  MDTodoItem.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MDTodoItem: Object, MDModelProtocol {
    @objc dynamic var id: Int = 0
    @objc dynamic var item: String = "Description"
    @objc dynamic var due: String = "NULL"
    @objc dynamic var completed: Int = 0
    
    var isCompleted: Bool {
        return completed == 1
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

extension MDTodoItem {
    
    convenience init(from json: JSON) {
        self.init()
        id = json["id"] as? Int ?? 0
        item = json["item"] as? String ?? "Description"
        due = json["due"] as? String ?? "NULL"
        completed = json["completed"] as? Int ?? 0
    }
    
}
