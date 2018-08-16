//
//  Videocall.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 10/6/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation
class Videocall: Codable {
    
    //MARK: Properties
    var id: Int
    var date: Int?
    var startDate:Int?
    var endDate:Int?
    var score:Int?
    var comment:String?
    var status:String?
    var note:String?
    var affiliate:Affiliate
    var doctor: Doctor
    
    //MARK: Initialization
    init?(id: Int, date: Int, startDate:Int, endDate:Int, score:Int, comment:String, status:String, note:String, affiliate:Affiliate, doctor: Doctor) {
        // Initialize stored properties.
        self.id = id
        self.date = date
        self.startDate = startDate
        self.endDate = endDate
        self.score = score
        self.comment = comment
        self.status = status
        self.note = note
        self.affiliate = affiliate
        self.doctor = doctor
    }
    
}
