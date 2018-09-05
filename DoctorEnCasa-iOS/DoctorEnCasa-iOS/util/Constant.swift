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
        static let APIBaseURL = "https://dec.ucmq.com:60630/doctorencasaapi/"
        static let mockToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZ3VzdGluYmFsYUBnbWFpbC5jb20iLCJhdWQiOiJ3ZWIiLCJleHAiOjE1MzI3MzkzNzYsImlhdCI6MTUzMjEzNDU3Nn0.mcXzIjo2E3ZUujL0g8VROn1odvaAaPuXn39Yh12Ld7Xh5f9e3WCRewsMowVppQQqg1KiC5Yu2P-XZ-i0--KIAA"
    }
    
    // MARK: Endpoints
    struct Endpoints {
        static let getMedicalRecord = "user/medicalrecord"
        static let forgotPassword = "user/password/reset"
        static let auth = "auth"
        static let provider = "provider"
        static let user = "user"
    }
    
    // MARK: Parameters
    struct Parameters {
        static let authorization = "Authorization"
        static let accept = "Accept"
        static let contentType = "Content-Type"
        static let jsonMimeType = "application/json"
        
    }
    
    // MARK: Parameters
    struct HTTPMethods {
        static let get = "GET"
        static let post = "POST"
        static let put = "PUT"
        static let delete = "DELETE"
    }
    
}
