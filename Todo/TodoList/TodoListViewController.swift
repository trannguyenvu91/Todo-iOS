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
    let viewModel = TodoListViewModel()
    var didSelectItem: ((MDTodoItem) -> Void)?
    @IBOutlet weak var tableView: UITableView!
    let refreshIndicator = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = MDTableViewDataSource(tableView: tableView, owner: self, dataProvider: viewModel, cellID: "Cell")
        tableView.addSubview(refreshIndicator)
        refreshIndicator.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        viewModel.finishUpdating = { [weak self] in
            self?.refreshIndicator.endRefreshing()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func deleteItem(at indexPath: IndexPath) {
        viewModel.deleteItem(at: indexPath)
    }
    
    @objc func refreshData() {
        refreshIndicator.beginRefreshing()
        viewModel.updateItems()
    }
    
}

extension TodoListViewController: MDTableViewDataSourceProtocol {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = viewModel.model(at: indexPath) as? MDTodoItem {
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
