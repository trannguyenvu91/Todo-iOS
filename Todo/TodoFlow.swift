//
//  TodoFlow.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit

class TodoFlow: NSObject {
    
    var navigationVC: UINavigationController!
    
    
    func setupRootVC(for window: UIWindow) {
        let storyBoard = getMainStoryBoard()
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationVC = UINavigationController(rootViewController: loginVC)
        navigationVC.delegate = self
        window.rootViewController = navigationVC
        window.makeKeyAndVisible()
        
        loginVC.loginSuccess = {
            self.presentTodoListVC()
        }
        loginVC.title = "Login"
    }
    
    func getMainStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    func presentTodoListVC() {
        let storyBoard = getMainStoryBoard()
        let todoListVC = storyBoard.instantiateViewController(withIdentifier: "TodoListViewController") as! TodoListViewController
        todoListVC.title = "Todo list"
        todoListVC.didSelectItem = { item in
            self.presentItemVC(item: item)
        }
        navigationVC.setViewControllers([todoListVC], animated: true)
    }
    
    func presentItemVC(item: MDTodoItem) {
        let storyBoard = getMainStoryBoard()
        let itemVC = storyBoard.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController
        itemVC.title = "Item detail"
        itemVC.item = item
        itemVC.completionSuccessful = { [weak self] in
            self?.navigationVC.popViewController(animated: true)
        }
        navigationVC.pushViewController(itemVC, animated: true)
    }
    
    @objc func presentCreateVC() {
        let storyBoard = getMainStoryBoard()
        let itemVC = storyBoard.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController
        itemVC.title = "Create New"
        itemVC.completionSuccessful = { [weak self] in
            self?.navigationVC.popViewController(animated: true)
        }
        navigationVC.pushViewController(itemVC, animated: true)
    }
    
}

extension TodoFlow: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let _ = viewController as? TodoListViewController {
            setupCreateNewButton(for: viewController)
        }
    }
    
    func setupCreateNewButton(for viewcontroller: UIViewController) {
        let barItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentCreateVC))
        viewcontroller.navigationItem.rightBarButtonItem = barItem
    }
    
}
