//
//  Util.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 12/6/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class Util {
    
    let formatter = DateFormatter()
    
    init?(){
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
    }
    
    func convertDate(date: Int!) -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(date))
        return formatter.string(from: date as Date)
    }
    
    func parseReason(reasons: [Reason]) -> String {
        var reason = ""
        for (_, element) in reasons.enumerated() {
            reason += (element as Reason).name + ", "
        }
        reason.removeLast()
        reason.removeLast()
        return reason
    }
    
}
