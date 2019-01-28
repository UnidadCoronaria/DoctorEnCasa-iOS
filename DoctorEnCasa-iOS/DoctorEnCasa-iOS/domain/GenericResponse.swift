//
//  GenericResponse.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 24/01/2019.
//  Copyright © 2019 Agustin. All rights reserved.
//

import Foundation

class GenericResponse: Codable {
    
    //MARK: Properties
    var code: Int
    var message: String
    
    //MARK: Initialization
    init?(code: Int, message:String) {
        // Initialize stored properties.
        self.code = code
        self.message = message
    }
    
}
