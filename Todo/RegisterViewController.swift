//
//  RegisterViewController.swift
//  Todo
//
//  Created by VuVince on 2/15/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    var loginSuccess: (() -> Void)?
    let viewModel = RegisterViewModel()
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.loginSuccess = loginSuccess
        viewModel.presentVC = { [weak self] viewcontroller in
            self?.present(viewcontroller, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpDidClick(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            email.count > 0, password.count > 0  else {
                return
        }
        viewModel.register(user: email, password: password)
    }
    
}

class RegisterViewModel: LoginViewModel {
    
    func register(user: String, password: String) {
        MDServerService.shareInstance().register(email: user, password: password, success: { [weak self] (response) in
            if let login = response["login"] as? String, login == "ok" {
                self?.login(user: user, password: password)
            } else if let errorMessage = response["error"] as? String {
                self?.loginError(message: errorMessage)
            } else {
                self?.loginError(message: "Login failed")
            }
        }) { [weak self] (error) in
            self?.loginError(message: error.getString)
        }
    }
    
}
