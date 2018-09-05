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
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.separatorColor = UIColor.gray
        tableView.isHidden = true
        // Load the sample data.
        loadProviders()
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
        cell.descriptionText.text = "Quilmes, Ezpeleta"
        return cell
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
            let parsedResult: [Provider]!
            do {
                parsedResult = try JSONDecoder().decode([Provider].self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.providers += parsedResult
                self.tableView.reloadData()
                self.tableView.isHidden = false
            })
            
            
        }).resume()
    }
}
