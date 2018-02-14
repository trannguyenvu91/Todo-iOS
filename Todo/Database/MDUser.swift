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

class MDUser: NSObject {
    var token = ""
    var id = ""
    
    static var sessionUser = MDUser()
}
