//
//  MedicalRecord.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 2/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation
class MedicalRecord {
    
    //MARK: Properties
    var date: String
    var detail: String
    
    //MARK: Initialization
    init?(date: String, detail: String) {
        // Initialization should fail if there is no name or if the rating is negative.
        if date.isEmpty {
            return nil
        }
        // Initialize stored properties.
        self.date = date
        self.detail = detail
        
    }
    
}
