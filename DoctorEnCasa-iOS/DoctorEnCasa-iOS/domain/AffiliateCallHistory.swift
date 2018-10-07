//
//  AffiliateCallHistory.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 24/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class AffiliateCallHistory : Codable {
    
    var lastVideocall: Videocall?
    var queries: Int?
    var waitTime: Double?
    
    
    //MARK: Initialization
    init?(videocall:Videocall, queries:Int, waitTime:Double){
        self.lastVideocall = videocall
        self.queries = queries
        self.waitTime = waitTime
    }

}
