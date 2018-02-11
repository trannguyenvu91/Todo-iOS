//
//  MDServerService.swift
//  Cinema
//
//  Created by VuVince on 9/21/17.
//  Copyright © 2017 VuVince. All rights reserved.
//

import UIKit
import Alamofire

typealias JSON = Dictionary<String, Any>

struct MDResource<T> {
    let URLRequest: URLRequest
    let parseResponse: ((Any?) -> T)?
}

class MDServerService: NSObject {
    private static let share = MDServerService()
    
    class func shareInstance() -> MDServerService {
        return MDServerService.share
    }
    
    func login(email: String, password: String, success: @escaping (JSON) -> Void, failure: @escaping MDRequestFailure) {
        let path = RoutingPath.login + "?username=" + email + "&password=" + password
        let request = URLRequest.mdRequest(path: path, method: .post, token: nil)
        let resource = MDResource<Any>(URLRequest: request!, parseResponse: nil)
        requestAPI(resource: resource, success: { (responseData) in
            success(responseData.1 as! JSON)
        }) { (error) in
            failure(error)
        }
    }
    
    
    //MARK: Generic request
    typealias MDResponseData = (String?, Any)
    typealias MDRequestSuccess = (MDResponseData) -> Void
    typealias MDRequestFailure = (Error) -> Void
    
    func requestAPI(resource: MDResource<Any>, success: @escaping MDRequestSuccess, failure: @escaping MDRequestFailure) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(resource.URLRequest)
            .validate()
            .responseJSON { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.returnCompletetion(resource: resource, response: response, success: success, failure: failure)
        }
    }
    
}

//MARK: Handle response and request completion
private extension MDServerService {
    
    func returnCompletetion(resource: MDResource<Any>, response: DataResponse<Any>, success: @escaping MDRequestSuccess, failure: @escaping MDRequestFailure) {
        switch response.result {
        case .success:
            guard let dataDict = response.result.value as? JSON else {
                failure(RountingError.parsingJSON)
                return
            }
            do {
                let parsedData = try self.parseData(from: dataDict)
                let result = resource.parseResponse?(parsedData.1) ?? parsedData.1
                success((parsedData.0, result))
            } catch {
                failure(error)
            }
        case .failure(let error):
            print(error.getString)
            failure(error)
            
        }
    }
    
    func parseData(from response: JSON) throws -> MDResponseData {
        if let _ = response["error"] as? String,
            let code = response["code"] as? Int,
            let error = RountingError(rawValue: code) {
            throw error
        }
        let message = response["message"] as? String
        let data = response["data"] ?? response
        return (message, data)
    }
    
    func request(path: String, method: HTTPMethod, token: String?) -> URLRequest? {
        guard let url = URL(string: RoutingPath.serverBaseURL + path) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let authToken = token {
            request.setValue(MDConstant.tokenPrefix + authToken, forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
}

extension URLRequest {
    
    static func mdRequest (path: String, method: HTTPMethod, token: String?) -> URLRequest? {
        guard let url = URL(string: RoutingPath.serverBaseURL + path) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let authToken = token {
            request.setValue(MDConstant.tokenPrefix + authToken, forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
}
