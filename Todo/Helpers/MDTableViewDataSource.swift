//
//  MDTableViewDataSource.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

 import UIKit

@objc protocol MDTableViewDataSourceProtocol: UITableViewDelegate {
    
}

//MARK: Initialization
class MDTableViewDataSource: NSObject {
    weak var tableView: UITableView!
    weak var owner: MDTableViewDataSourceProtocol!
    weak var dataProvider: MDListProviderProtocol!
    var reusedCellID: String!
    
    init(tableView: UITableView, owner: MDTableViewDataSourceProtocol, dataProvider: MDListProviderProtocol, cellID: String) {
        super.init()
        self.tableView = tableView
        self.owner = owner
        self.dataProvider = dataProvider
        self.reusedCellID = cellID
        setup()
    }
    
    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        dataProvider.updatesNotification = {[weak self] deletions, insertions, modifications in
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: insertions, with: .automatic)
            self?.tableView.deleteRows(at: deletions, with: .automatic)
            self?.tableView.reloadRows(at: modifications, with: .automatic)
            self?.tableView.endUpdates()
        }
        dataProvider.reloadNotification = {[weak self] in
            self?.tableView.reloadData()
        }
    }
    
}

//MARK: UITableViewDataSource
extension MDTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusedCellID) as! UITableViewCell & MDModelViewProtocol
        let model = dataProvider.model(at: indexPath)
        cell.setup(with: model)
        return cell
    }
    
}

//MARK: UITableViewDelegate
extension MDTableViewDataSource: UITableViewDelegate {
    
    override func responds(to aSelector: Selector!) -> Bool {
        if owner.responds(to: aSelector) {
            return true
        }
        return super.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if owner.responds(to: aSelector) {
            return owner
        }
        return super.forwardingTarget(for: aSelector)
    }
    
}
