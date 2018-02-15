//
//  LoginViewController.swift
//  Todo
//
//  Created by VuVince on 2/10/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class LoginViewController: UIViewController {

    var loginSuccess: (() -> Void)?
    var signUpCallBack: (() -> Void)?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewModel.loginSuccess = loginSuccess
        viewModel.presentVC = { [weak self] viewcontroller in
            self?.present(viewcontroller, animated: true, completion: nil)
        }
    }

    @IBAction func btnLoginClicked(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            email.count > 0, password.count > 0  else {
            return
        }
        viewModel.login(user: email, password: password)
    }
    
    @IBAction func btnSignupClicked(_ sender: Any) {
        signUpCallBack?()
    }
    
}

class LoginViewModel: NSObject {

    var presentVC: ((UIViewController) -> Void)?
    var loginSuccess: (() -> Void)?
    
    func login(user: String, password: String) {
        MDServerService.shareInstance().login(email: user, password: password, success: { [weak self] (response) in
            if let token = response["token"] as? String {
                MDUser.sessionUser.email = user
                MDUser.sessionUser.token = token
                self?.didLogin()
            } else if let errorMessage = response["error"] as? String {
                self?.loginError(message: errorMessage)
            } else {
                self?.loginError(message: "Login failed")
            }
        }) { [weak self] (error) in
            self?.loginError(message: error.getString)
        }
    }
    
    func loginError(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Login error", message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            self.presentVC?(alert)
        }
    }
    
    func didLogin() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            realm.add(MDUser.sessionUser, update: true)
        }
        loginSuccess?()
    }
    
}

