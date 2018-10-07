//
//  ChangePasswordViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 23/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class ChangePasswordViewController : UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var currentPasswordText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var newPasswordRepeatText: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    
    @IBAction func changePassword(_ sender: Any) {
        
        if (currentPasswordText.text?.isEmpty)! {
            return
        }
        if (newPasswordText.text?.isEmpty)! {
            return
        }
        if (newPasswordRepeatText.text?.isEmpty)! {
            return
        }
        
        if (newPasswordRepeatText.text != newPasswordText.text) {
            showNotMatchingPasswords()
            return
        }
        
        doChangePassword()
    }

    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func doChangePassword(){
       
        let url:URL = URL(string: Constants.API.APIBaseURL + Constants.Endpoints.changePassword)!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = Constants.HTTPMethods.put
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        //Get token
        if let token : String = UserDefaults.standard.value(forKey: NavigationUtil.DATA.tokenKey) as? String {
            request.setValue(token, forHTTPHeaderField: Constants.Parameters.authorization)
        }
        let credential : Credential = Credential(password: currentPasswordText.text!, newPassword: newPasswordText.text!)
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
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            DispatchQueue.main.async(execute: {
                
                let alert : UIAlertController = UIAlertController(title: "Exito", message: "Se ha cambiado la contraeña correctamente.", preferredStyle: .alert)
                alert.isModalInPopover = true
                let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(actionAcept)
                self.present(alert, animated: true, completion: nil)
                
            })
            
            
        }).resume()
    }
    
    private func showSuccess(){
        let alert : UIAlertController = UIAlertController(title: "Exito", message: "Se ha cambiado la contraeña correctamente.", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNotMatchingPasswords(){
        let alert : UIAlertController = UIAlertController(title: "Error", message: "Las contraseñas no coinciden.", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
        }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }
}
