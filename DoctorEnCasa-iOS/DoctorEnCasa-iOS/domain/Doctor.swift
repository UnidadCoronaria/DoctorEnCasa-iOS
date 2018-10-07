//
//  Doctor.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 11/6/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation
class Doctor: Codable {
    
    //MARK: Properties
    //MARK: Properties
    var id: Int
    var username: String
    var email: String
    var enabled:Bool
    var lastPasswordResetDate:Int
    var passwordExpired:Bool
    var tokenGcm:String?
    var firstName: String?
    var lastName:String?
    var age:Int
    var sex: String
    var nationalEnrollment:String
    var documentNumber:String
    var online:Bool
    var available: Bool
    
    //MARK: Initialization
    init?(id: Int, username:String, email: String, enabled:Bool, lastPasswordResetDate:Int, passwordExpired:Bool,
          tokenGcm:String, firstName: String, lastName:String, age:Int, sex: String, nationalEnrollment:String,
          documentNumber:String, online:Bool, available: Bool) {
        // Initialize stored properties.
        self.id = id
        self.username = username
        self.email = email
        self.enabled = enabled
        self.lastPasswordResetDate = lastPasswordResetDate
        self.passwordExpired = passwordExpired
        self.tokenGcm = tokenGcm
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.sex = sex
        self.nationalEnrollment = nationalEnrollment
        self.documentNumber = documentNumber
        self.online = online
        self.available = available
    }
    


    
}
