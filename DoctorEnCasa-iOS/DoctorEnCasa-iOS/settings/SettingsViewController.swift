//
//  SettingsViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 16/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit


class SettingsViewController : UIViewController {
    
    @IBOutlet weak var changePasswordText: UILabel!
    @IBOutlet weak var rateAppText: UILabel!
    @IBOutlet weak var showTermsText: UILabel!
    @IBOutlet weak var logoutText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let gestureLogout = UITapGestureRecognizer(target: self, action: #selector(logout(_:)))
        logoutText.addGestureRecognizer(gestureLogout)
        
        let gestureRateApp = UITapGestureRecognizer(target: self, action: #selector(rateApp(_:)))
        rateAppText.addGestureRecognizer(gestureRateApp)
        
        let gestureTerms = UITapGestureRecognizer(target: self, action: #selector(showTerms(_:)))
        showTermsText.addGestureRecognizer(gestureTerms)
        
        let gestureChangePassword = UITapGestureRecognizer(target: self, action: #selector(changePassword(_:)))
        changePasswordText.addGestureRecognizer(gestureChangePassword)
    }
    
    @objc func rateApp(_ sender: Any){
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id..."),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
        
    
    @objc func logout(_ sender: Any){
        let alert : UIAlertController = UIAlertController(title: "", message: "¿Estás seguro de que querés cerrar tu sesión?", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
            self.doLogout()
        }
        alert.addAction(actionAcept)
        let actionCancel:UIAlertAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default) { (_:UIAlertAction) in
            alert.dismiss(animated: true, completion: {});
        }
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
       
    }
    
    func doLogout(){
        //Clear user's token
        UserDefaults.standard.removeObject(forKey: NavigationUtil.DATA.tokenKey)
        
        //Dismiss this VC
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
        //Navigate back to login
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.loginNavigation)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
     @objc func showTerms(_ sender: Any){
         self.performSegue(withIdentifier: "showTerms", sender: nil)
    }
    
    @objc func changePassword(_ sender: Any){
        self.performSegue(withIdentifier: "showChangePassword", sender: nil)
    }
    
}
