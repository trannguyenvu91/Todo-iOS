//
//  TodoListViewModel.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class TodoListViewModel: NSObject, MDListProviderProtocol {
    
    var items: Results<MDTodoItem>?
    var reloadNotification: (() -> Void)?
    var updatesNotification: (([IndexPath], [IndexPath], [IndexPath]) -> Void)?
    var notificationToken: NotificationToken? = nil
    var finishUpdating: (() -> Void)?
    
    override init() {
        super.init()
        fetchItems()
        perform(#selector(updateTodos), with: nil, afterDelay: 1)
    }
    
    @objc func updateTodos() {
        MDServerService.shareInstance().getAllItems(token: MDUser.sessionUser.token, success: { [weak self] (todoItems) in
            MDDatabase.shareInstance.saveModels(models: todoItems, update: true)
            let realm = try! Realm()
            try! realm.write {
                MDUser.sessionUser.todos.replaceSubrange(0..<MDUser.sessionUser.todos.count, with: todoItems)
            }
            self?.finishUpdating?()
        }) { [weak self] (err) in
            print(err.getString)
            self?.finishUpdating?()
        }
    }
    
    func fetchItems() {
        items = MDUser.sessionUser.todos.sorted(byKeyPath: "id")
        notificationToken = items?._observe({ [weak self] (changes) in
            switch changes {
            case .initial:
                self?.reloadNotification?()
            case .update(_, let deletions, let insertions, let modifications):
                let delPaths = deletions.map{IndexPath(row: $0, section: 0)}
                let insertPaths = insertions.map{IndexPath(row: $0, section: 0)}
                let modifyPaths = modifications.map{IndexPath(row: $0, section: 0)}
                self?.updatesNotification?(delPaths, insertPaths, modifyPaths)
            case .error(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func deleteTodo(at indexPath: IndexPath) {
        let item = items![indexPath.row]
        MDServerService.shareInstance().deleteItem(token: MDUser.sessionUser.token, itemID: item.id, success: {(_) in
            let realm = try! Realm()
            try! realm.write {
                realm.delete(item)
            }
        }, failure: { (error) in
            print(error.getString)
        })
    }
    
    func model(at indexPath: IndexPath) -> MDModelProtocol? {
        return items?[indexPath.row]
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(in section: Int) -> Int {
        return items!.count
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
}
