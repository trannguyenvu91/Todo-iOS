//
//  Extension.swift
//  CookRecipes
//
//  Created by VuVince on 2/8/18.
//

protocol BackendError: Error {
    var description: String { get }
    var code: Int { get }
}

enum RountingError: Int, BackendError {
    
    case missingToken = 100
    case missingParam = 101
    
    case tokenInvalid = 200
    
    case stROM = 300
    
    case parsingJSON = 400
    
    var code: Int {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .missingParam:
            return "Missing param"
        case .missingToken:
            return "Missing token"
        case .tokenInvalid:
            return "Token invalid"
        case .stROM:
            return "Database error"
        case .parsingJSON:
            return "Data format invalid"
        }
    }
    
}

extension Error {
    
    var getString: String {
        if let err = self as? BackendError {
            return err.description
        }
        return localizedDescription
    }
    
}

