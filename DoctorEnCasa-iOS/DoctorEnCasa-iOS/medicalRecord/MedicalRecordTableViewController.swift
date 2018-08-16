//
//  MedicalRecordTableViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 2/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class MedicalRecordTableViewController: UITableViewController {
    
    //MARK: Properties
    let pullToRefresh = UIRefreshControl()
    var medicalRecords = [MedicalRecord]()
    var selectedMedicalRecord:MedicalRecord!
    let util = Util()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add pull to refresh
        pullToRefresh.attributedTitle = NSAttributedString(string: "Recargar la lista de consultas médicas")
        pullToRefresh.addTarget(self, action: #selector(MedicalRecordTableViewController.reload), for: .valueChanged)
        tableView.addSubview(pullToRefresh)
        tableView.separatorColor = UIColor.black
        // Load the sample data.
        loadMedicalRecords()
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
        cell.recommentations.text =  String(medicalRecord.recommendation)
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "See Detail") { (action, indexPath) in
            print("In action " + String(indexPath.row))
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "medicalRecordDetail") as! MedicalRecordDetailViewController
            myVC.detail = self.medicalRecords[indexPath.row];
            self.navigationController?.pushViewController(myVC, animated: true)
            self.tableView.setEditing(false, animated: true)
        }
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMedicalRecord = self.medicalRecords[indexPath.row];
        self.performSegue(withIdentifier: "showMedicalRecordDetail", sender: nil)
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
        getRequest.setValue(Constants.API.mockToken, forHTTPHeaderField: Constants.Parameters.authorization)
        
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
