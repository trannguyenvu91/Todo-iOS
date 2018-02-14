//
//  MDTodoItem.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit

class MDTodoItem: NSObject, MDModelProtocol {
    var id: Int = 0
    var item: String = "Description"
    var due: String = "NULL"
    var completed: Int = 0
    var associatedUser: String = ""
    
    init(from json: JSON) {
        super.init()
        id = json["id"] as? Int ?? 0
        item = json["item"] as? String ?? "Description"
        due = json["due"] as? String ?? "NULL"
        completed = json["completed"] as? Int ?? 0
        associatedUser = json["associatedUser"] as? String ?? ""
    }
    
    var isCompleted: Bool {
        return completed == 1
    }
    
}
