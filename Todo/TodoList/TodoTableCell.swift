//
//  TodoTableCell.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit

class TodoTableCell: UITableViewCell, MDModelViewProtocol {
    func setup(with model: MDModelProtocol?) {
        guard let todo = model as? MDTodoItem else { return }
        textLabel?.text = todo.item
        detailTextLabel?.text = todo.due
    }

}
