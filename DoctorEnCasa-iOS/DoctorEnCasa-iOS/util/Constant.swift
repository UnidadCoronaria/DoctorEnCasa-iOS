//
//  Constant.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 9/6/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: API
    struct API {
        static let APIBaseURL : String = Bundle.main.object(forInfoDictionaryKey: "BaseURLKey") as! String
    }
    
    // MARK: Endpoints
    struct Endpoints {
        static let getMedicalRecord = "user/medicalrecord"
        static let forgotPassword = "user/password/reset"
        static let auth = "auth"
        static let provider = "provider"
        static let user = "user"
        static let changePassword = "user/password"
        static let userHistory = "user/history"
        static let queueStatus = "queue/status"
        static let videocall = "videocall"
        static let updateTokenGCM = "user/updateTokenGCM"
        static let rank = "videocall/ranking"
        static let cancel = "videocall/cancel"

    }
    
    // MARK: Parameters
    struct Parameters { 
        static let authorization = "Authorization"
        static let accept = "Accept"
        static let contentType = "Content-Type"
        static let jsonMimeType = "application/json"
        static let tokenGCM = "TokenGCM"
        
    }
    
    // MARK: Parameters
    struct HTTPMethods {
        static let get = "GET"
        static let post = "POST"
        static let put = "PUT"
        static let delete = "DELETE"
    }
    
}
