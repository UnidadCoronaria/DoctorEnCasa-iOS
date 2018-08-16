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
    var lastPasswordResetDate:Int
    var passwordExpired:Bool
    var tokenGcm:String?
    var groupNumber: Int
    var provider: Provider
    
    //MARK: Initialization
    init?(id: Int, username:String, email: String, enabled:Bool, lastPasswordResetDate:Int, passwordExpired:Bool,
          tokenGcm:String, groupNumber: Int, provider: Provider) {
        // Initialize stored properties.
        self.id = id
        self.username = username
        self.email = email
        self.enabled = enabled
        self.lastPasswordResetDate = lastPasswordResetDate
        self.passwordExpired = passwordExpired
        self.tokenGcm = tokenGcm
        self.groupNumber = groupNumber
        self.provider = provider
    }
    
}
