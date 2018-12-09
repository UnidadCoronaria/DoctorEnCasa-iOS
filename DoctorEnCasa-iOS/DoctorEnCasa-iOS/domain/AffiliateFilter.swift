//
//  AffiliateFilter.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 11/11/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class AffiliateFilter: Codable {
    
    //MARK: Properties
    var firstName: String?
    var lastName: String?
    var affiliateGamId: String?
    
    //MARK: Initialization
    init?(firstName: String, lastName: String, affiliateGamId : String) {
        // Initialize stored properties.
        self.firstName = firstName
        self.lastName = lastName
        self.affiliateGamId = affiliateGamId
    }
    
}
