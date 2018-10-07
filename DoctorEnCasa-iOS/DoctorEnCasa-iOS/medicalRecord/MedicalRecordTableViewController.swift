//
//  MedicalRecordTableViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 2/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class MedicalRecordTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    
    //MARK: Properties
    let pullToRefresh = UIRefreshControl()
    var medicalRecords = [MedicalRecord]()
    var selectedMedicalRecord:MedicalRecord!
    let util = Util()
    let filterOption = ["Item 1", "Item 2", "Item 3"]
    var token : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get token
        if let token : String = UserDefaults.standard.value(forKey: NavigationUtil.DATA.tokenKey) as? String {
           self.token = token
        }
        
        // add pull to refresh
        pullToRefresh.attributedTitle = NSAttributedString(string: "Recargar la lista de consultas médicas")
        pullToRefresh.addTarget(self, action: #selector(MedicalRecordTableViewController.reload), for: .valueChanged)
        tableView.addSubview(pullToRefresh)
        tableView.separatorColor = UIColor.black
        
        //create  navigation bar filter button
        let filterButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(filter))
        self.navigationItem.rightBarButtonItem = filterButton
        
        // Load the sample data.
        loadMedicalRecords()
    }
    
    
    @objc func filter(){
        let alert : UIAlertController = UIAlertController(title: "Buscar", message: "Afiliado", preferredStyle: .alert)
        alert.isModalInPopover = true
    
        let pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 140)) // CGRectMake(left, top, width, height) - left and top are like margins
        pickerFrame.tag = 555
        //set the pickers datasource and delegate
        pickerFrame.delegate = self
        
        

        //Add the picker to the alert controller
        alert.view.addSubview(pickerFrame)
        
        
        let action1:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in print("Aceptar")}
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil) 
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(filterOption[row])
    }
    
    @objc func reload() {
        self.tableView.reloadData()
        pullToRefresh.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return medicalRecords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalRecordTableViewCell", for: indexPath)  as? MedicalRecordTableViewCell else {
            fatalError("The dequeued cell is not an instance of MedicalRecordTableViewCell.")
        }
        // Fetches the appropriate meal for the data source layout.
        let medicalRecord = medicalRecords[indexPath.row]
        cell.date.text = util?.convertDate(date: medicalRecord.videocall.date!)
        cell.name.text =  String(describing:medicalRecord.firstName!+" "+medicalRecord.lastName!)
        cell.reasons.text =  util?.parseReason(reasons: medicalRecord.reasons!)
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMedicalRecord = self.medicalRecords[indexPath.row];
        self.performSegue(withIdentifier: NavigationUtil.NAVIGATE.showMedicalRecordDetail, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? MedicalRecordDetailViewController {
            dvc.detail = self.selectedMedicalRecord
        }
    }
    
    //MARK: Private Methods
    private func loadMedicalRecords() {
        let url:URL = URL(string: Constants.API.APIBaseURL+Constants.Endpoints.getMedicalRecord)!
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
            let parsedResult: [MedicalRecord]!
            do {
                parsedResult = try JSONDecoder().decode([MedicalRecord].self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.medicalRecords += parsedResult
                self.tableView.reloadData()
            })
            
           
        }).resume()
    }

    
}
