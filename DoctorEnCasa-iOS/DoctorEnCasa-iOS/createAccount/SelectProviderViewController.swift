//
//  SelectProviderViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 02/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class SelectProviderViewController: UITableViewController {
    
    var providers = [Provider]()
    var selectedProvider:Provider!
    var loadingView : UIView?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if providers.count == 0{
            self.loadingView = UIViewController.displaySpinner(onView: self.view)
        }
        tableView.separatorColor = UIColor.gray
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //create  navigation bar filter button
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(doBack))
        self.navigationItem.leftBarButtonItem = backButton
        // Load the sample data.
        if providers.count == 0{
            loadProviders()
        }
        
        self.tableView.tableFooterView = UIView()
    }
    
    @objc func doBack(){
        //Dismiss this VC
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
        //Navigate back to login
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.loginNavigation)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return providers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderTableViewCell", for: indexPath)  as? ProviderTableViewCell else {
            fatalError("The dequeued cell is not an instance of ProviderTableViewCell.")
        }
        // Fetches the appropriate meal for the data source layout.
        let provider = providers[indexPath.row]
        cell.nameText.text =  provider.name
        cell.descriptionText.text = provider.zones
        cell.icon.image = UIImage(named: getIcon(providerId: provider.id))
        return cell
    }
    
    private func getIcon (providerId : Int) -> String {
        switch providerId {
        case 1:
            return "logo_unidad_coronaria"
        case 2:
            return "logo_emeca_salud"
        case 3:
            return "logo_ayuda_medica"
        case 4:
            return "logo_sume_salud"
        case 5:
            return "logo_ayuda_medica"
        default:
            return "logo_ayuda_medica"
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedProvider = self.providers[indexPath.row];
        self.performSegue(withIdentifier: NavigationUtil.NAVIGATE.showCreateAccountForm, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? CreateAccountViewController {
            dvc.provider = self.selectedProvider
       }
    }
    
    func loadProviders(){
        let url:URL = URL(string: Constants.API.APIBaseURL+Constants.Endpoints.provider)!
        var getRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        getRequest.httpMethod = Constants.HTTPMethods.get
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.contentType)
        getRequest.setValue(Constants.Parameters.jsonMimeType, forHTTPHeaderField: Constants.Parameters.accept)
        
        URLSession.shared.dataTask(with: getRequest, completionHandler: { (data, response, error) -> Void in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                self.showError()
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                self.showError()
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                self.showError()
                return
            }
            
            // parse the data
            let parsedResult: [Provider]!
            do {
                parsedResult = try JSONDecoder().decode([Provider].self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                self.showError()
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.providers += parsedResult
                self.tableView.reloadData()
                UIViewController.removeSpinner(spinner: self.loadingView!)
                self.tableView.isHidden = false
            })
            
            
        }).resume()
    }

    private func showError(){
        DispatchQueue.main.async(execute: {
            self.tableView.isHidden = true
            let alert : UIAlertController = UIAlertController(title: "Error", message: "Hubo un error obteniendo la lista de empresas, por favor intentá más tarde", preferredStyle: .alert)
            alert.isModalInPopover = true
            let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(actionAcept)
            self.present(alert, animated: true, completion: nil)
        })
    }
}
