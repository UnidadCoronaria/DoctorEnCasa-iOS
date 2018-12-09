//
//  VideocallRank.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 04/11/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class VideocallRank : Codable {
    
    private var videocallId:Int
    private var score:Int
    private var comment:String
    
    init(videocallId : Int, score : Int, comment: String){
        self.videocallId = videocallId
        self.score = score
        self.comment = comment
    }
}
