//
//  User.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 24/7/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class UserInfo: Codable {
    
    //MARK: Properties
    var token: String
    var user: Affiliate
    
    //MARK: Initialization
    init?(token: String, user: Affiliate) {
        // Initialize stored properties.
        self.token = token
        self.user = user
    }
    
}

