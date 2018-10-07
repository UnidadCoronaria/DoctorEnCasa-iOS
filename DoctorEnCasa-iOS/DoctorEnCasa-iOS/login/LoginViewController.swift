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
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var forgot: UITextField!
    @IBOutlet weak var createAccountText: UITextField!
    var usernameValue: String?
    var passwordValue: String?
    
    @IBAction func forgotPassword(_ sender: Any) {
        self.performSegue(withIdentifier: NavigationUtil.NAVIGATE.showForgotPassword, sender: nil)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
        let storyBoard = UIStoryboard(name: "CreateAccount", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.createAccountNavigation)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    //MARK: Actions
    @IBAction func login(_ sender: UIButton) {
        self.submit.isEnabled = false;
        perfomLogin()
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
        error.isHidden = true
    
        let gesture = UITapGestureRecognizer(target: self, action: #selector(forgotPassword(_:)))
        forgot.addGestureRecognizer(gesture)
        
        let gestureAccount = UITapGestureRecognizer(target: self, action: #selector(createAccount(_:)))
        createAccountText.addGestureRecognizer(gestureAccount)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        username.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    private func perfomLogin() {
        let url:URL = URL(string: Constants.API.APIBaseURL + Constants.Endpoints.auth)!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = Constants.HTTPMethods.post
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        let credential : Credential = Credential(username: username.text!, password: password.text!)
        let data : Data
        do {
            let jsonEncoder = JSONEncoder()
            data = try jsonEncoder.encode(credential)
            request.httpBody = data
        } catch {
            print("Error: cannot create JSON from credentials")
            return
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                // remove loading
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                DispatchQueue.main.async(execute: {
                    self.error.isHidden = false
                    self.submit.isEnabled = true
                })
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: UserInfo!
            do {
                parsedResult = try JSONDecoder().decode(UserInfo.self, from: data)
                UserDefaults.standard.set(parsedResult.token, forKey: NavigationUtil.DATA.tokenKey)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            DispatchQueue.main.async(execute: {
                self.error.isHidden = true
                self.submit.isEnabled = true
                self.password.text = ""
               
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.main)
                UIApplication.shared.keyWindow?.rootViewController = vc
                
            })
            
            
        }).resume()
    }

}

