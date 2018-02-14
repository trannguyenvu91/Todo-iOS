//
//  TodoListViewController.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit

class TodoListViewController: UIViewController {

    var dataSource: MDTableViewDataSource!
    let dataProvider = MDTodoListProvider()
    var didSelectItem: ((MDTodoItem) -> Void)?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = MDTableViewDataSource(tableView: tableView, owner: self, dataProvider: dataProvider, cellID: "Cell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataProvider.getItems()
    }
    
    func deleteItem(at indexPath: IndexPath) {
        dataProvider.deleteItem(at: indexPath)
    }
    
}

extension TodoListViewController: MDTableViewDataSourceProtocol {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = dataProvider.model(at: indexPath) as? MDTodoItem {
            didSelectItem?(item)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (anAction, anIndexPath) in
            self?.deleteItem(at: anIndexPath)
        }
        return [delete]
    }
    
}
