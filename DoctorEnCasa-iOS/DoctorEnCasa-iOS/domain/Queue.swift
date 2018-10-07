//
//  Queue.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 24/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class Queue : Codable {
    
    var doctorsAttending : Int?
    var usersQueue : Int?
    var waitTime : Double
    
    //MARK: Initialization
    init?(doctorsAttending:Int, usersQueue:Int, waitTime:Double){
        self.doctorsAttending = doctorsAttending
        self.usersQueue = usersQueue
        self.waitTime = waitTime
    }


}
