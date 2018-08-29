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
    var username: String
    var password: String
    
    //MARK: Initialization
    init?(username: String, password: String) {
        // Initialization should fail if there is no name or if the rating is negative.
        if username.isEmpty {
            return nil
        }
        // Initialize stored properties.
        self.username = username
        self.password = password
        
    }
    
}
