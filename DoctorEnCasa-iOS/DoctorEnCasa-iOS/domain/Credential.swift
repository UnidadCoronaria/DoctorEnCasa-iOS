//
//  Credential.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 1/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation
class Credential: Encodable {
    
    //MARK: Properties
    var username: String?
    var password: String?
    var newPassword: String?
    var email: String?
    var groupNumber: Int?
    var providerId: Int?
    
    
    //MARK: Initialization
    init(){
        
    }
    
    convenience init(username: String, password: String) {
        self.init()
        // Initialize stored properties.
        self.username = username
        self.password = password
        
    }
    
    convenience init(password: String, newPassword: String) {
        self.init()
        // Initialize stored properties.
        self.password = password
        self.newPassword = newPassword
        
    }
    
    convenience init(username: String, password: String, email: String, groupNumber: Int, providerId: Int) {
        self.init(username: username, password: password)
        // Initialize stored properties.
        self.email = email
        self.groupNumber = groupNumber
        self.providerId = providerId
    }
    
    convenience init(email: String){
        self.init()
        self.email = email
    }
    
}
