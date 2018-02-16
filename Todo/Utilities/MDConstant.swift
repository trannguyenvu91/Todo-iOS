//
//  MDConstant.swift
//  Cinema
//
//  Created by VuVince on 9/21/17.
//  Copyright © 2017 VuVince. All rights reserved.
//

import UIKit

struct RoutingPath {
    static let login = "/api/v1/login"
    static let register = "/api/v1/register"
    static let count = "/api/v1/count"
    static let getAll = "/api/v1/get/all"
    static let create = "/api/v1/create"
    static let update = "/api/v1/update"
    static let delete = "/api/v1/delete"
    static let extendToken = "/api/v1/extendToken"
    
    static let serverBaseURL = "http://0.0.0.0:8181"
}

public struct MDConstant {
    
    //MARK: Date time
    static let dateFormater = DateFormatter()
    static let dateFormat = "HH:MM:SS DD/MM/YYYY"
    
    static func getDate(_ dateString: String) -> Date? {
        dateFormater.dateFormat = dateFormat
        return dateFormater.date(from: dateString)
    }
    
    static func getString(date: Date?) -> String {
        guard let value = date else { return "NULL" }
        return dateFormater.string(from: value)
    }
    
    static func getCurrentDate() -> Date {
        return Date()
    }
    
    static func now() -> Int {
        return Int(Date.timeIntervalSinceReferenceDate)
    }
    
    //MARK: Token prefix
    static let tokenPrefix = "CookRecipes_"
    static let tokenIdleTime = 7 * 24 * 3600
    
}
