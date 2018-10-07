//
//  Provider.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 11/6/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation
class Provider: Codable {
    
    //MARK: Properties
    var id: Int
    var name: String
    var url: String
    var zones: String
    
    //MARK: Initialization
    init?(id: Int, name:String, url: String, zones: String) {
        // Initialize stored properties.
        self.id = id
        self.name = name
        self.url = url
        self.zones = zones
    }
    
}
