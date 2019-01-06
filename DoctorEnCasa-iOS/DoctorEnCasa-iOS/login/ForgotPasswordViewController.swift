//
//  ForgotPasswordViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 29/08/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var errorText: UILabel!
    var loadingView : UIView?

    @IBAction func sendMail(_ sender: Any) {
        if !(self.emailText.text?.isEmpty)! && Util.isValidMail(email: emailText.text!)  {
            self.errorText.isHidden = true
            self.loadingView = UIViewController.displaySpinner(onView: self.view)
            self.perfomSend()
        } else{
            self.errorText.isHidden = false
        }
        
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.delegate = self
        errorText.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailText.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailText.resignFirstResponder()
    }
    
    private func perfomSend() {
        let url:URL = URL(string: Constants.API.APIBaseURL + Constants.Endpoints.forgotPassword)!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = Constants.HTTPMethods.put
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        let credential : Credential = Credential(email: emailText.text!)
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
                DispatchQueue.main.async(execute: {
                    self.errorText.isHidden = false
                })
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.errorText.isHidden = true
                UIViewController.removeSpinner(spinner: self.loadingView!)
                
                let alert : UIAlertController = UIAlertController(title: "Exito", message: "Se ha enviado un mail con la nueva contraseña.", preferredStyle: .alert)
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
}


