//
//  LoginViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 3/3/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate  {
    
    //MARK: Properties
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    var usernameValue: String?
    var passwordValue: String?
    
    //MARK: Actions
    @IBAction func login(_ sender: UIButton) {
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.delegate = self
        password.delegate = self
    }

}

