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
    
    var loadingView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changePasswordButton.layer.cornerRadius = 15
        changePasswordButton.layer.borderWidth = 1
        changePasswordButton.layer.borderColor = UIColor.clear.cgColor
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if UserDefaults.standard.value(forKey: "passwordExpired") != nil {
            if (UserDefaults.standard.value(forKey: "passwordExpired") as? Bool)! {
                let alert : UIAlertController = UIAlertController(title: "Actualizar contraseña", message: "Actualizá tu contraseña antes de continuar.", preferredStyle: .alert)
                alert.isModalInPopover = true
                let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
                    alert.dismiss(animated: false, completion: {
                        
                    })
                }
                alert.addAction(actionAcept)
                self.present(alert, animated: true, completion: nil)
            }
        }
       
    }

    
    @IBAction func changePassword(_ sender: Any) {
        
        if (currentPasswordText.text?.isEmpty)! {
            showNotMissingField()
            return
        }
        if (newPasswordText.text?.isEmpty)! {
            showNotMissingField()
            return
        }
        if (newPasswordRepeatText.text?.isEmpty)! {
            showNotMissingField()
            return
        }
        
        if (newPasswordRepeatText.text != newPasswordText.text) {
            showNotMatchingPasswords()
            return
        }
        self.loadingView = UIViewController.displaySpinner(onView: self.view)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
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
            UIViewController.removeSpinner(spinner: self.loadingView!)
            return
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
            }
            
            func checkStatusCode() {
                // parse the data
                let parsedErrorData: GenericResponse!
                do {
                    if let errorData = data {
                        parsedErrorData = try JSONDecoder().decode(GenericResponse.self, from: errorData)
                        if parsedErrorData.code == 1003 {
                            DispatchQueue.main.async(execute: {
                                self.showDialog(message: "La contraseña ingresada es incorrecta.")
                                UIViewController.removeSpinner(spinner: self.loadingView!)
                                return
                            })
                        } else {
                            displayError("Unknown error code")
                            UIViewController.removeSpinner(spinner: self.loadingView!)
                            return
                        }
                    }
                } catch {
                    displayError("Your request returned a status code other than 2xx!")
                    UIViewController.removeSpinner(spinner: self.loadingView!)
                    return
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 408 {
                SessionUtil.logout(vc: self)
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                checkStatusCode()
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                displayError("No data was returned by the request!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                UIViewController.removeSpinner(spinner: self.loadingView!)
                UserDefaults.standard.set(false, forKey: "passwordExpired")

                let alert : UIAlertController = UIAlertController(title: "Exito", message: "Se ha cambiado la contraeña correctamente. Por favor, ingresá nuevamente.", preferredStyle: .alert)
                alert.isModalInPopover = true
                let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
                    SessionUtil.logout(vc: self)
                }
                alert.addAction(actionAcept)
                self.present(alert, animated: true, completion: nil)
                
            })
            
            
        }).resume()
    }

    
    private func showNotMatchingPasswords(){
        let alert : UIAlertController = UIAlertController(title: "Error", message: "Las contraseñas no coinciden.", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
        }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNotMissingField(){
        let alert : UIAlertController = UIAlertController(title: "Error", message: "Los campos no pueden estar vacíos.", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
        }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDialog(message : String){
        let alert : UIAlertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
            alert.dismiss(animated: true, completion: {});
        }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }
}
