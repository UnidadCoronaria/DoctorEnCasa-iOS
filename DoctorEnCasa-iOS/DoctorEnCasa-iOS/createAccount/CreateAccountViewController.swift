//
//  CreateAccountViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 02/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class CreateAccountViewController : UIViewController,  UITextFieldDelegate {

   
    @IBOutlet weak var repeatePasswordText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var affiliateNumberText: UITextField!
    @IBOutlet weak var mailText: UITextField!
   
    @IBOutlet weak var finalizeButton: UIButton!
    @IBOutlet weak var repeatPasswordError: UILabel!
    @IBOutlet weak var mailError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var termsAndConditions: UISwitch!
    
    var loadingView : UIView?
    
    var provider:Provider!
    var affiliate:Affiliate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordText.delegate = self
        self.mailText.delegate = self
        self.affiliateNumberText.delegate = self
        self.repeatePasswordText.delegate = self
        self.finalizeButton.isEnabled = false
        self.repeatPasswordError.isHidden = true
        self.mailError.isHidden = true
        self.passwordError.isHidden = true
    }
   
    @IBAction func endEditingAffiliateNumber(_ sender: Any) {
        if let affiliateNumber = affiliateNumberText.text {
            if(affiliateNumber.count > 1){
                if let affiliate = self.affiliate {
                    let fullName = affiliate.firstName! + " " + affiliate.lastName!
                    let tempValue = "\(affiliateNumber) - \(fullName)"
                    if affiliateNumber == tempValue {
                        return
                    }
                }
                getAffiliate();
            } else {
                self.finalizeButton.isEnabled = false
            }
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        self.affiliateNumberText.text = ""
        self.affiliate = nil
        self.finalizeButton.isEnabled = false
    }

    
    @IBAction func finalize(_ sender: Any) {
        self.mailError.isHidden = true
        self.repeatPasswordError.isHidden = true
        self.passwordError.isHidden = true
        
        if !termsAndConditions.isOn {
            showMissingTermsAndConditions()
            return
        }
        
        if mailText.text == nil || !Util.isValidMail(email: mailText.text!) {
            self.mailError.isHidden = false
            return
        }
        
        if passwordText.text == nil || (passwordText.text?.count)! < 6 {
            self.passwordError.isHidden = false
            return
        }
        
        if repeatePasswordText.text == nil || (repeatePasswordText.text?.count)! < 6 {
            self.repeatPasswordError.isHidden = false
            return
        }
        
        if passwordText.text != repeatePasswordText.text {
            showMissmatchPasswords()
            return
        }
        self.loadingView = UIViewController.displaySpinner(onView: self.view)
        createUser()
    }
    
    func showMissmatchPasswords(){
        let alert : UIAlertController = UIAlertController(title: "Error", message: "Las contraseñas no coinciden.", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMissingTermsAndConditions(){
        let alert : UIAlertController = UIAlertController(title: "Error", message: "Tenés que aceptar los términos y condiciones.", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func getAffiliate(){
        let affiliateNumber = affiliateNumberText.text!
        let providerId = String(provider.id)
        let urlString = String((Constants.API.APIBaseURL + "provider/" + providerId + "/group/" + affiliateNumber).split(separator: " ")[0] + "/owner")
        let url:URL = URL(string: urlString)!
        var getRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        getRequest.httpMethod = Constants.HTTPMethods.get
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        
        URLSession.shared.dataTask(with: getRequest, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                DispatchQueue.main.async(execute: {
                    self.finalizeButton.isEnabled = false
                })
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: Affiliate!
            do {
                parsedResult = try JSONDecoder().decode(Affiliate.self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.affiliate = parsedResult
                self.afterGetAffiliates()
            })
            
            
        }).resume()
    }
    
    func afterGetAffiliates(){
        if let affiliate = self.affiliate{
            let fullName = "\(String(describing: affiliate.firstName!)) \(String(describing: affiliate.lastName!))"
            let affiliateNumberTemp = String(self.affiliateNumberText.text!.split(separator: " ")[0])
            self.affiliateNumberText.text = "\(affiliateNumberTemp) - \(fullName)"
            self.finalizeButton.isEnabled = true
        } else {
            self.affiliateNumberText.text = String(self.affiliateNumberText.text!.split(separator: " ")[0])
            self.finalizeButton.isEnabled = false
        }
    }
    
    func createUser(){
        let url:URL = URL(string: Constants.API.APIBaseURL + "user")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = Constants.HTTPMethods.post
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        
        let credential : Credential = Credential(username: mailText.text!, password: passwordText.text!, email: mailText.text!, groupNumber: Int(String((affiliateNumberText.text?.split(separator: " ")[0])!))!, providerId: provider.id)
        let data : Data
        do {
            let jsonEncoder = JSONEncoder()
            data = try jsonEncoder.encode(credential)
            request.httpBody = data
        } catch {
            print("Error: cannot create JSON from credentials")
            UIViewController.removeSpinner(spinner: self.loadingView!)
            return
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                 DispatchQueue.main.async(execute: {
                    self.showErrorDialog()
                 })
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            // parse the data
            let parsedResult: UserInfo!
            do {
                parsedResult = try JSONDecoder().decode(UserInfo.self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                UIViewController.removeSpinner(spinner: self.loadingView!)
                
                UserDefaults.standard.set(parsedResult.token, forKey: NavigationUtil.DATA.tokenKey)
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.main)
                UIApplication.shared.keyWindow?.rootViewController = vc
            })
            
            
        }).resume() 
    }
    
    func showErrorDialog(){
        let alert : UIAlertController = UIAlertController(title: "Error", message: "Hubo un error creando tu usuario. Por favor, intentalo en un momento.", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
             alert.dismiss(animated: true, completion: {});
        }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }
    
}
