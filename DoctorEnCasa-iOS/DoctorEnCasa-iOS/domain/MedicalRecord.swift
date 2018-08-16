//
//  MedicalRecord.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 2/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation
class MedicalRecord: Codable {
    
    //MARK: Properties
    var id: Int
    var recommendation: String
    var affiliateGamId: String
    var lastName: String?
    var firstName: String?
    var videocall: Videocall
    var reasons: [Reason]?
    
    //MARK: Initialization
    init?(id: Int, recommendation:String, affiliateGamId: String, lastName: String, firstName: String, reasons: [Reason], videocall: Videocall) {
        // Initialize stored properties.
        self.id = id
        self.affiliateGamId = affiliateGamId
        self.recommendation = recommendation
        self.lastName = lastName
        self.firstName = firstName
        self.reasons = reasons
        self.videocall = videocall
    }
    
}
