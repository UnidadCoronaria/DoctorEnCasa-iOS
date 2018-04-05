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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add pull to refresh
        pullToRefresh.attributedTitle = NSAttributedString(string: "Recargar la lista de consultas médicas")
        pullToRefresh.addTarget(self, action: #selector(MedicalRecordTableViewController.reload), for: .valueChanged)
        tableView.addSubview(pullToRefresh)
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
        cell.date.text = medicalRecord.date
        cell.detail.text = medicalRecord.detail

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
        guard let medicalRecord1 = MedicalRecord(date: "02/04/2018", detail: "Atendido por Juan Blanco") else {
            fatalError("Unable to instantiate meal1")
        }
        guard let medicalRecord2 = MedicalRecord(date: "01/04/2018", detail: "Atendido por Juan Blanco") else {
            fatalError("Unable to instantiate meal1")
        }
        medicalRecords += [medicalRecord1, medicalRecord2]
    }
    

}
