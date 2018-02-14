//
//  MDTodoListProvider.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit

class MDTodoListProvider: NSObject, MDListProviderProtocol {
    
    var items = [MDTodoItem]()
    var reloadNotification: (() -> Void)?
    var updatesNotification: (([IndexPath], [IndexPath], [IndexPath]) -> Void)?
    
    override init() {
        super.init()
        getItems()
    }
    
    func getItems() {
        MDServerService.shareInstance().getAllItems(token: MDUser.sessionUser.token, success: { [weak self] (items) in
            self?.items = items
            self?.reloadNotification?()
        }) { (err) in
            print(err.getString)
        }
    }
    
    func deleteItem(at indexPath: IndexPath) {
        let item = items[indexPath.row]
        MDServerService.shareInstance().deleteItem(token: MDUser.sessionUser.token, itemID: item.id, success: { [weak self] (_) in
            guard let index = self?.items.index(of: item) else { return }
            self?.items.remove(at: index)
            self?.updatesNotification?([IndexPath(row: index, section: 0)], [], [])
        }, failure: { (error) in
            print(error.getString)
        })
    }
    
    func model(at indexPath: IndexPath) -> MDModelProtocol? {
        return items[indexPath.row]
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return items.count
    }
    
}
