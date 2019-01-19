//
//  VideocallViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 24/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//
import StoreKit
import UIKit

class VideocallViewController : UIViewController {
    
    let pullToRefresh = UIRefreshControl()
    var timer = Timer()
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var queueText: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorView: UIView!
    
    var token : String = ""
    var affiliateCallHistory : AffiliateCallHistory?
    var queueStatus : Queue?
    var currentVideocall : Videocall?
   
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.errorView.isHidden = true
        //First request to avoid 30 sec waiting
        getCurrentState()
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(VideocallViewController.reload), userInfo: nil, repeats: true)
        
        if let lastCallStatus = UserDefaults.standard.string(forKey: "LAST_CALL_STATUS") {
            UserDefaults.standard.set(nil, forKey: "LAST_CALL_STATUS")
            
            switch lastCallStatus {
            case "CALL_EXPIRED":
                self.showInfoAlert(title: "Llamada no disponible", text: "La llamada ya no se encuenta disponible, en breve podrás sacar otro turno")
                break
            case "CALL_REJECTED":
                self.showInfoAlert(title: "Llamada rechazada", text: "Rechazaste la llamada, en breve podrás sacar otro turno..")
                break
            case "CALL_TIMEOUT":
                self.showInfoAlert(title: "Llamada no disponible", text: "No atendiste a tiempo, en breve podrás sacar otro turno")
                break
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get token
        if let token : String = UserDefaults.standard.value(forKey: NavigationUtil.DATA.tokenKey) as? String {
            self.token = token
        }
        
        // add pull to refresh
        pullToRefresh.attributedTitle = NSAttributedString(string: "Recargar el estado de tus videollamadas")
        pullToRefresh.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        //scrollView.addSubview(pullToRefresh)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
        cancelButton.layer.cornerRadius = 15
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.clear.cgColor
        
        
    }
    
    @IBAction func beNext(_ sender: Any) {
        self.createCall()
    }
    
    @IBAction func cancel(_ sender: Any) {
        let alert : UIAlertController = UIAlertController(title: "Cancelar turno", message: "¿Estás seguro que querés cancelar tu turno?", preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Si", style: UIAlertActionStyle.destructive) { (_:UIAlertAction) in self.cancelCall() }
        alert.addAction(actionAcept)
        let actionNo:UIAlertAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in  }
        alert.addAction(actionNo)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func reload() {
        self.getCurrentState()
        pullToRefresh.endRefreshing()
    }
    
    private func reloadScreenInfo(){
        separator.isHidden = false
        image.image = UIImage(named: "icono_home")
       
        if (affiliateCallHistory != nil && affiliateCallHistory?.lastVideocall != nil) {
            self.errorView.isHidden = true
            self.currentVideocall = affiliateCallHistory?.lastVideocall
            if("FINALIZADA" == affiliateCallHistory?.lastVideocall?.status
                || "EXPIRADA" == affiliateCallHistory?.lastVideocall?.status
                || "CERRADA" == affiliateCallHistory?.lastVideocall?.status
                || "CANCELADA" == affiliateCallHistory?.lastVideocall?.status) {
                descriptionText.text = "Sacá un turno para ser atendido por uno de nuestros doctores"
                button.isHidden = false
                cancelButton.isHidden = true
                
                checkForAppRanking()
                
            } else {
                button.isHidden = true
                if("EN_COLA" == affiliateCallHistory?.lastVideocall?.status){
                    //Si hay call activa y esta en cola
                    descriptionText.text = "¡Ya te encuentras en lista de espera!\nTe llamaremos cuando haya un doctor disponible"
                    cancelButton.isHidden = false
                } else {
                    cancelButton.isHidden = true
                    if("LISTA_ATENCION" == affiliateCallHistory?.lastVideocall?.status){
                        // Si hay call activa y esta lista para atenderse
                        descriptionText.text = "¡Ya hay un médico disponible para vos!\n¡Te va a estar llamando en cualquier momento!"
                    } else {
                        if("EN_PROGRESO" == affiliateCallHistory?.lastVideocall?.status){
                            // Si hay call activa y esta en proceso
                            descriptionText.text = "¡Ya tenés una consulta en progreso!"
                        }
                    }
                    descriptionText.text = "¡Ya hay un médico disponible para vos!\n¡Te va a estar llamando en cualquier momento!";
                }
            }
        } else {
            if(affiliateCallHistory != nil){
                self.currentVideocall = affiliateCallHistory?.lastVideocall
                self.errorView.isHidden = true
                descriptionText.text = "Sacá un turno para ser atendido por uno de nuestros doctores"
                button.isHidden = false
                cancelButton.isHidden = true
            } else {
                self.errorView.isHidden = false
                cancelButton.isHidden = true
            }
        }
        
        //ACTUALIZAR PANTALLA SEGUN ESTADO
        getQueueStatus()
    }
    
    private func checkForAppRanking(){
        if UserDefaults.standard.value(forKey: "appOpenings") != nil {
            let currentOpenings = UserDefaults.standard.integer(forKey: "appOpenings")
            if UserDefaults.standard.value(forKey: "rankedApp") == nil && currentOpenings > 5{
                    if #available(iOS 10.3, *) {
                        SKStoreReviewController.requestReview()
                        UserDefaults.standard.setValue(true, forKey: "rankedApp")
                    }
            }
        }
    }
    
    private func reloadQueueStatus(){
        queueText.isHidden = false
        if Double((queueStatus?.waitTime)!) > 0.0 {
            queueText.text = "La demora estimada para que el doctor te atienda es de 5 minutos"
        } else if Double((queueStatus?.waitTime)!) == 0.0 {
            queueText.text = "¡Hay médicos disponibles para atenderte en este momento!"
        } else {
            queueText.text = "¡Hay una espera estimada de 10 minutos!"
        }
    }
    
    private func errorInHistory(){
        self.errorView.isHidden = false
        queueText.isHidden = true
        button.isHidden = true
        cancelButton.isHidden = true
        separator.isHidden = true
    }
    
    private func errorGetQueue(){
        queueText.isHidden = true
    }
    
    private func showInfoAlert(title : String, text : String) {
        let alert : UIAlertController = UIAlertController(title: title, message:text , preferredStyle: .alert)
        alert.isModalInPopover = true
        let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in self.reload() }
        alert.addAction(actionAcept)
        self.present(alert, animated: true, completion: nil)
    }

    
    private func getCurrentState(){
        let url:URL = URL(string: Constants.API.APIBaseURL+Constants.Endpoints.userHistory)!
        var getRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        getRequest.httpMethod = Constants.HTTPMethods.get
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        getRequest.setValue(self.token, forHTTPHeaderField: Constants.Parameters.authorization)
        
        URLSession.shared.dataTask(with: getRequest, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                DispatchQueue.main.async(execute: {
                    self.errorInHistory()
                })
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 408 {
                SessionUtil.logout(vc: self)
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
            let parsedResult: AffiliateCallHistory!
            do {
                parsedResult = try JSONDecoder().decode(AffiliateCallHistory.self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.affiliateCallHistory = parsedResult
                self.reloadScreenInfo()
            })
            
            
        }).resume()
    }
    
    private func getQueueStatus(){
        let url:URL = URL(string: Constants.API.APIBaseURL+Constants.Endpoints.queueStatus)!
        var getRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        getRequest.httpMethod = Constants.HTTPMethods.get
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        getRequest.setValue(self.token, forHTTPHeaderField: Constants.Parameters.authorization)
        
        URLSession.shared.dataTask(with: getRequest, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                DispatchQueue.main.async(execute: {
                   self.errorGetQueue()
                })
                // remove loading
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 408 {
                SessionUtil.logout(vc: self)
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
            let parsedResult: Queue!
            do {
                parsedResult = try JSONDecoder().decode(Queue.self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.queueStatus = parsedResult
                self.reloadQueueStatus()
            })
            
            
        }).resume()
    }
    
    private func createCall(){
        let url:URL = URL(string: Constants.API.APIBaseURL+Constants.Endpoints.videocall)!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = Constants.HTTPMethods.post
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        request.setValue(self.token, forHTTPHeaderField: Constants.Parameters.authorization)

        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                DispatchQueue.main.async(execute: {
                    self.errorGetQueue()
                })
                // remove loading
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 408 {
                SessionUtil.logout(vc: self)
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                displayError("No data was returned by the request!")
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.reload()
            })
            
            
        }).resume()
    }
    
    private func cancelCall(){
        let url:URL = URL(string: Constants.API.APIBaseURL+Constants.Endpoints.cancel)!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = Constants.HTTPMethods.post
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        request.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        request.setValue(self.token, forHTTPHeaderField: Constants.Parameters.authorization)
        let rank : VideocallDTO = VideocallDTO(videocallId: (self.currentVideocall?.id)!)
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
                DispatchQueue.main.async(execute: {
                    self.showInfoAlert(title: "Error", text: "Hubo un error cancelando el turno. Por favor, intentalo nuevamente.")
                })
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 408 {
                SessionUtil.logout(vc: self)
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard data != nil else {
                displayError("No data was returned by the request!")
                return
            }
            
            DispatchQueue.main.async(execute: {
                DispatchQueue.main.async(execute: {
                    self.showInfoAlert(title: "Turno cancelado", text: "Tu turno fue cancelado satisfactoriamente.")
                })
            })
            
            
        }).resume()
    }
}
