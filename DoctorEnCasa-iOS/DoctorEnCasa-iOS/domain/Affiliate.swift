//
//  Affiliate.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 11/6/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class Affiliate: Codable {
    
    //MARK: Properties
    var id: Int
    var username: String
    var email: String
    var enabled:Bool
    var passwordExpired:Bool
    var tokenGcm:String?
    var provider: Provider
    
    //MARK: Initialization
    init?(id: Int, username:String, email: String, enabled:Bool, passwordExpired:Bool,
          tokenGcm:String, provider: Provider) {
        // Initialize stored properties.
        self.id = id
        self.username = username
        self.email = email
        self.enabled = enabled
        self.passwordExpired = passwordExpired
        self.tokenGcm = tokenGcm
        self.provider = provider
    }
    
}
