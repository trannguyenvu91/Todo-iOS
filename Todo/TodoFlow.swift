//
//  TodoFlow.swift
//  Todo
//
//  Created by VuVince on 2/14/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class TodoFlow: NSObject {
    
    var navigationVC: UINavigationController!
    
    func setupRootVC(for window: UIWindow) {
        let rootVC = hasLogin() ? getTodoListVC() : getLoginVC()
        navigationVC = UINavigationController(rootViewController: rootVC)
        navigationVC.delegate = self
        window.rootViewController = navigationVC
        window.makeKeyAndVisible()
    }
    
    func presentTodoListVC() {
        let todoListVC = getTodoListVC()
        navigationVC.setViewControllers([todoListVC], animated: true)
    }
    
    func presentItemVC(item: MDTodoItem) {
        let itemVC = getItemVC(item: item)
        navigationVC.pushViewController(itemVC, animated: true)
    }
    
    @objc func presentCreateVC() {
        let itemVC = getItemVC(item: nil)
        itemVC.title = "Create New"
        navigationVC.pushViewController(itemVC, animated: true)
    }
    
    func presentSignUpVC() {
        let signUpVC = getRegisterVC()
        navigationVC.pushViewController(signUpVC, animated: true)
    }
    
    @objc func logout() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        MDUser.clearSessionUser()
        let loginVC = getLoginVC()
        navigationVC.setViewControllers([loginVC], animated: true)
    }
    
    func hasLogin() -> Bool {
        let token = MDUser.sessionUser.token
        return token.count > 0
    }
    
}

extension TodoFlow: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let _ = viewController as? TodoListViewController {
            setupCreateNewButton(for: viewController)
            setupLogoutButton(for: viewController)
        }
    }
    
    func setupCreateNewButton(for viewcontroller: UIViewController) {
        let barItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentCreateVC))
        viewcontroller.navigationItem.rightBarButtonItem = barItem
    }
    
    func setupLogoutButton(for viewcontroller: UIViewController) {
        let barItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logout))
        viewcontroller.navigationItem.leftBarButtonItem = barItem
    }
    
}

//MARK: Get ViewControllers
extension TodoFlow {
    
    func getTodoListVC() -> UIViewController {
        let storyBoard = getMainStoryBoard()
        let todoListVC = storyBoard.instantiateViewController(withIdentifier: "TodoListViewController") as! TodoListViewController
        todoListVC.title = "Todo list"
        todoListVC.didSelectTodo = { [weak self] item in
            self?.presentItemVC(item: item)
        }
        return todoListVC
    }
    
    func getLoginVC() -> UIViewController {
        let storyBoard = getMainStoryBoard()
        let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.loginSuccess = { [weak self] in
            self?.presentTodoListVC()
        }
        loginVC.signUpCallBack = { [weak self] in
            self?.presentSignUpVC()
        }
        loginVC.title = "Login"
        return loginVC
    }
    
    func getItemVC(item: MDTodoItem?) -> UIViewController {
        let storyBoard = getMainStoryBoard()
        let itemVC = storyBoard.instantiateViewController(withIdentifier: "ItemViewController") as! TodoViewController
        itemVC.title = "Item detail"
        itemVC.todo = item
        itemVC.completionSuccessful = { [weak self] in
            self?.navigationVC.popViewController(animated: true)
        }
        return itemVC
    }
    
    func getRegisterVC() -> UIViewController {
        let storyBoard = getMainStoryBoard()
        let registerVC = storyBoard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        registerVC.loginSuccess = { [weak self] in
            self?.presentTodoListVC()
        }
        registerVC.title = "Create new"
        return registerVC
        
    }
    
    func getMainStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
}
