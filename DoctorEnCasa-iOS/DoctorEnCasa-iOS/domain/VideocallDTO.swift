//
//  VideocallDTO.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 17/01/2019.
//  Copyright © 2019 Agustin. All rights reserved.
//

import Foundation

class VideocallDTO : Codable {
    
    private var videocallId:Int
    
    init(videocallId : Int){
        self.videocallId = videocallId
    }
}
