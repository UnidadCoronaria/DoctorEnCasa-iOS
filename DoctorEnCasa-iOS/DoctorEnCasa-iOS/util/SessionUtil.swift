//
//  SessionUtil.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 26/12/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation
import UIKit

class SessionUtil {
    
    static func logout(vc : UIViewController){
        //Clear user's token
        UserDefaults.standard.removeObject(forKey: NavigationUtil.DATA.tokenKey)
        UserDefaults.standard.removeObject(forKey: NavigationUtil.DATA.provider)
        
        //Dismiss this VC
        vc.navigationController?.popViewController(animated: true)
        vc.dismiss(animated: true, completion: nil)
        
        //Navigate back to login
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.loginNavigation)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
}
