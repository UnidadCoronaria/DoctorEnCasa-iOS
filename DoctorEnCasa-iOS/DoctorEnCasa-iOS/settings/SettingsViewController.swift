//
//  SettingsViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 16/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit


class SettingsViewController : UITableViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    
    @IBAction func rateApp(_ sender: Any){
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
        
    
    @IBAction func logout(_ sender: Any){
        let alert : UIAlertController = UIAlertController(title: "", message: "¿Estás seguro de que querés cerrar tu sesión?", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
            SessionUtil.logout(vc: self)
        }
        alert.addAction(actionAcept)
        let actionCancel:UIAlertAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default) { (_:UIAlertAction) in
            alert.dismiss(animated: true, completion: {});
        }
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
       
    }
  
    
}
