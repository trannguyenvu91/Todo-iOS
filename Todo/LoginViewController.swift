//
//  LoginViewController.swift
//  Todo
//
//  Created by VuVince on 2/10/18.
//  Copyright © 2018 VuVince. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let viewModel = LoginViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    }
    
}

class LoginViewModel: NSObject {
    
    func login(user: String, password: String) {
        MDServerService.shareInstance().login(email: user, password: password, success: { (data) in
            print(data)
        }) { (error) in
            print(error.getString)
        }
    }
    
}

