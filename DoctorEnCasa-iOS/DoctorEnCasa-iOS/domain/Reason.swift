//
//  Reason.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 10/6/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class Reason: Codable {
    
    //MARK: Properties
    var id: Int
    var name: String
    var description: String
    
    //MARK: Initialization
    init?(id: Int, name:String, description: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.description = description
    }
    
}
