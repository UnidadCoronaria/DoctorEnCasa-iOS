//
//  ApiClient.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 5/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import Foundation

class ApiClient {
    
    func get(url:URL) {
        //var getURL = URL(string: "https://httpbin.org/get?bar=foo")!
        var getRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        getRequest.httpMethod = "GET"
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    getRequest.setValue("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZ3VzdGluYmFsYUBnbWFpbC5jb20iLCJhdWQiOiJ3ZWIiLCJleHAiOjE1MjU1NzMxODcsImlhdCI6MTUyNDk2ODM4N30.OAKdufvHqVa8zRYIZI9sBPgLewmhLa_PoYRcrikRrnALZAfRwRt0CaW2S8KDuhH3Re8bXmoy2UIHEizR2fYEkQ", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: getRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil { print("GET Request: Communication error: \(error!)") }
            if data != nil {
                do {
                    let resultObject = try JSONSerialization.jsonObject(with: data!, options: [])
                    DispatchQueue.main.async(execute: {
                        print("Results from GET \(url.absoluteString) :\n\(resultObject)") })
                    
                } catch {
                    DispatchQueue.main.async(execute: {
                        print("Unable to parse JSON response")
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                })
            }
        }).resume()
    }
    
    func post(url:URL, parameters: [String: Any]) {
        var postRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60.0)
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    
    
       // let parameters: [String: Any] = ["foo": "bar", "numbers": [1, 2, 3, 4, 5]]
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options: [])
            postRequest.httpBody = jsonParams
        } catch { print("Error: unable to add parameters to POST request.")}
        
        URLSession.shared.dataTask(with: postRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil { print("POST Request: Communication error: \(error!)") }
            if data != nil {
                do {
                    let resultObject = try JSONSerialization.jsonObject(with: data!, options: [])
                    DispatchQueue.main.async(execute: {
                        print("Results from POST \(url.absoluteString) :\n\(resultObject)")
                    })
                } catch {
                    DispatchQueue.main.async(execute: {
                        print("Unable to parse JSON response")
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    print("Received empty response.")
                })
            }
        }).resume()
    }

}
