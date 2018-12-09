//
//  RankCallViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 04/11/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class RankCallViewController : UIViewController {
    
    public var videocallId : Int?
    private var score: Int = 1
    
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let star1Gesture = UITapGestureRecognizer(target: self, action: #selector(star1Click(_:)))
        star1.addGestureRecognizer(star1Gesture)
        let star2Gesture = UITapGestureRecognizer(target: self, action: #selector(star2Click(_:)))
        star2.addGestureRecognizer(star2Gesture)
        let star3Gesture = UITapGestureRecognizer(target: self, action: #selector(star3Click(_:)))
        star3.addGestureRecognizer(star3Gesture)
        let star4Gesture = UITapGestureRecognizer(target: self, action: #selector(star4Click(_:)))
        star4.addGestureRecognizer(star4Gesture)
        let star5Gesture = UITapGestureRecognizer(target: self, action: #selector(star5Click(_:)))
        star5.addGestureRecognizer(star5Gesture)
        
      
    }
    
    @objc func star1Click(_ sender: Any) {
        score = 1
        star1.isHighlighted = true
        star2.isHighlighted = false
        star3.isHighlighted = false
        star4.isHighlighted = false
        star5.isHighlighted = false
    }
    
    @objc func star2Click(_ sender: Any) {
        score = 2
        star1.isHighlighted = true
        star2.isHighlighted = true
        star3.isHighlighted = false
        star4.isHighlighted = false
        star5.isHighlighted = false
    }
    
    @objc func star3Click(_ sender: Any) {
        score = 3
        star1.isHighlighted = true
        star2.isHighlighted = true
        star3.isHighlighted = true
        star4.isHighlighted = false
        star5.isHighlighted = false
    }
    
    @objc func star4Click(_ sender: Any) {
        score = 4
        star1.isHighlighted = true
        star2.isHighlighted = true
        star3.isHighlighted = true
        star4.isHighlighted = true
        star5.isHighlighted = true
    }
    
    @objc func star5Click(_ sender: Any) {
        score = 5
        star1.isHighlighted = true
        star2.isHighlighted = true
        star3.isHighlighted = true
        star4.isHighlighted = true
        star5.isHighlighted = true
    }
    
    
    @IBAction func notNow(_ sender: Any) {
        self.backToMain()
    }
    
    @IBAction func send(_ sender: Any) {
        self.performSend()
    }
    
    private func performSend(){
        let url:URL = URL(string: Constants.API.APIBaseURL + Constants.Endpoints.rank)!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = Constants.HTTPMethods.post
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        let rank : VideocallRank = VideocallRank(videocallId: videocallId!, score: score, comment: commentText.text!)
        let data : Data
        do {
            let jsonEncoder = JSONEncoder()
            data = try jsonEncoder.encode(rank)
            request.httpBody = data
        } catch {
            print("Error: cannot create JSON from ranking data")
            return
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                self.showError()
                // remove loading
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: Videocall!
            do {
                parsedResult = try JSONDecoder().decode(Videocall.self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            DispatchQueue.main.async(execute: {
                if self.score > 3 {
                    self.backToMain()
                } else {
                    self.showCallOffices()
                }
               
            })
            
            
        }).resume()
    }
    
    private func backToMain(){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.main)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func showError(){
        DispatchQueue.main.async(execute: {
            let alert : UIAlertController = UIAlertController(title: "Error", message: "Hubo un error enviando tus comentarios. Por favor, intentalo nuevamente.", preferredStyle: .alert)
            alert.isModalInPopover = true
            let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in }
            alert.addAction(actionAcept)
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    func showCallOffices(){
        DispatchQueue.main.async(execute: {
            let alert : UIAlertController = UIAlertController(title: "Comentarios enviados", message: "Hubo un error enviando tus comentarios. Por favor, intentalo nuevamente.", preferredStyle: .alert)
            alert.isModalInPopover = true
            let actionAcept:UIAlertAction = UIAlertAction(title: "Si", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
                guard let number = URL(string: "tel://" + self.getTelephone()) else { return }
                UIApplication.shared.open(number, options: [:], completionHandler: nil)
                self.backToMain()
                
            }
             let actionCancel:UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in  self.backToMain()}
            alert.addAction(actionAcept)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    private func getTelephone() -> String{
        var tel = ""
        if let provider : Int = UserDefaults.standard.value(forKey: NavigationUtil.DATA.provider) as? Int {
            switch provider{
            case 1:  tel = "1142577777"
            case 2:  tel = "1142240202"
            case 5:  tel = "08102227100"
            case 4:  tel = "1148607000"
            case 3:  tel = "1142243600"
            default:
                tel = "1142577777"
            }
        }
        return tel
    }
}
