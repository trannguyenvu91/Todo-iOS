//
//  MDUser.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MDUser: Object {
    @objc dynamic var token = ""
    @objc dynamic var email = ""
    var todos = List<MDTodoItem>()
    
    private static var _user: MDUser?
    
    static var sessionUser: MDUser {
        if _user == nil {
            _user = initializeUser()
        }
        return _user!
    }
    
    override static func primaryKey() -> String? {
        return "email"
    }
    
    private class func initializeUser() -> MDUser {
        let realm = try! Realm()
        if let user = realm.objects(MDUser.self).first {
            return user
        }
        return MDUser()
    }
    
    class func clearSessionUser() {
        _user = nil
    }
    
}
