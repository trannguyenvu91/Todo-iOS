//
//  ItemViewController.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ItemViewController: UIViewController {
    
    var item: MDTodoItem?
    var completionSuccessful: (() -> Void)?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueTextField: UITextField!
    @IBOutlet weak var completedSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = item?.item
        dueTextField.text = item?.due
        completedSwitch.isOn = item?.isCompleted ?? false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSaveDidClicked(_ sender: Any) {
        guard let title = titleTextField.text, let due = dueTextField.text else { return }
        let token = MDUser.sessionUser.token
        
        if item == nil {
            createNew(token: token, item: title, due: due)
        } else {
            editItem(token: token, item: title, due: due)
        }
    }
    
    func createNew(token: String, item: String, due: String) {
        MDServerService.shareInstance().createItem(token: token, item: item, due: due, success: { [weak self] (todo) in
            self?.save(todo: todo)
            self?.completionSuccessful?()
            }, failure: { (err) in
                print(err.getString)
        })
    }
    
    func editItem(token: String, item: String, due: String) {
        let completed = completedSwitch.isOn ? 1 : 0
        MDServerService.shareInstance().editItem(token: token, item: item, due: due, id: (self.item?.id)!, completed: completed, success: { [weak self] (todo) in
            self?.save(todo: todo)
            self?.completionSuccessful?()
        }) { (err) in
            print(err.getString)
        }
    }
    
    func save(todo: MDTodoItem) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(todo, update: true)
        }
    }
    
}
