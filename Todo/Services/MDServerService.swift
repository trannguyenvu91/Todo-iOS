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
        let request = URLRequest.mdRequest(path: RoutingPath.login, method: .post, token: nil, param: ["username": email, "password": password])
        let resource = MDResource<Any>(URLRequest: request!, parseResponse: nil)
        requestAPI(resource: resource, success: { (responseData) in
            success(responseData.1 as! JSON)
        }) { (error) in
            failure(error)
        }
    }
    
    func signUp(email: String, password: String, success: @escaping (JSON) -> Void, failure: @escaping MDRequestFailure) {
        let request = URLRequest.mdRequest(path: RoutingPath.register, method: .post, token: nil, param: ["username": email, "password": password])
        let resource = MDResource<Any>(URLRequest: request!, parseResponse: nil)
        requestAPI(resource: resource, success: { (responseData) in
            success(responseData.1 as! JSON)
        }) { (error) in
            failure(error)
        }
    }
    
    func getAllItems(token: String, success: @escaping ([MDTodoItem]) -> Void, failure: @escaping MDRequestFailure) {
        let request = URLRequest.mdRequest(path: RoutingPath.getAll, method: .get, token: token, param: nil)
        let resource = MDResource<[MDTodoItem]>(URLRequest: request!) { (data) -> [MDTodoItem] in
            if let json = data as? JSON, let arr = json["items"] as? [JSON] {
                return arr.map{MDTodoItem(from: $0)}
            }
            return []
        }
        requestAPI(resource: resource, success: { (responseData) in
            success(responseData.1 as! [MDTodoItem])
        }) { (error) in
            failure(error)
        }
    }
    
    func deleteItem(token: String, itemID: Int, success: @escaping (Bool) -> Void, failure: @escaping MDRequestFailure) {
        let path = RoutingPath.delete
        let request = URLRequest.mdRequest(path: path, method: .delete, token: token, param: ["id": itemID])
        let resource = MDResource<Any>(URLRequest: request!, parseResponse: nil)
        requestAPI(resource: resource, success: { (responseData) in
            success(true)
        }) { (error) in
            failure(error)
        }
    }
    
    func createItem(token: String, item: String, due: String, success: @escaping (MDTodoItem) -> Void, failure: @escaping MDRequestFailure) {
        let request = URLRequest.mdRequest(path: RoutingPath.create, method: .post, token: token, param: ["item": item, "due": due])
        let resource = MDResource<MDTodoItem>(URLRequest: request!) { (data) -> MDTodoItem in
            if let json = data as? JSON, let arr = json["items"] as? JSON {
                return MDTodoItem(from: arr)
            }
            return MDTodoItem(from: [:])
        }
        requestAPI(resource: resource, success: { (responseData) in
            success(responseData.1 as! MDTodoItem)
        }) { (error) in
            failure(error)
        }
    }
    
    func editItem(token: String, item: String, due: String, id: Int, completed: Int, success: @escaping (MDTodoItem) -> Void, failure: @escaping MDRequestFailure) {
        let request = URLRequest.mdRequest(path: RoutingPath.update, method: .post, token: token, param: ["item": item, "due": due, "id": id, "completed": completed])
        let resource = MDResource<MDTodoItem>(URLRequest: request!) { (data) -> MDTodoItem in
            if let json = data as? JSON, let arr = json["item"] as? JSON {
                return MDTodoItem(from: arr)
            }
            return MDTodoItem(from: [:])
        }
        requestAPI(resource: resource, success: { (responseData) in
            success(responseData.1 as! MDTodoItem)
        }) { (error) in
            failure(error)
        }
    }
    
    
    //MARK: Generic request
    typealias MDResponseData = (String?, Any)
    typealias MDRequestSuccess = (MDResponseData) -> Void
    typealias MDRequestFailure = (Error) -> Void
    
    func requestAPI<T>(resource: MDResource<T>, success: @escaping MDRequestSuccess, failure: @escaping MDRequestFailure) {
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
    
    func returnCompletetion<T>(resource: MDResource<T>, response: DataResponse<Any>, success: @escaping MDRequestSuccess, failure: @escaping MDRequestFailure) {
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
    
    static func mdRequest (path: String, method: HTTPMethod, token: String?, param: JSON?) -> URLRequest? {
        guard let url = URL(string: RoutingPath.serverBaseURL + path) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let authToken = token {
            request.setValue(MDConstant.tokenPrefix + authToken, forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20
        return try! URLEncoding().encode(request, with: param)
    }
    
}
