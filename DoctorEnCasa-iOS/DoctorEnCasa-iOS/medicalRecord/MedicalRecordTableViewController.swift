//
//  MedicalRecordTableViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 2/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class MedicalRecordTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var previosRecordsTitle: UILabel!
    @IBOutlet weak var firstItemContainer: UIStackView!
    @IBOutlet weak var errorView: UIView!
    
    //MARK: Properties
    let pullToRefresh = UIRefreshControl()
    var medicalRecords = [MedicalRecord]()
    var filteredMedicalRecords = [MedicalRecord]()
    var firstMedicalRecord : MedicalRecord!
    var selectedMedicalRecord:MedicalRecord!
    let util = Util()
    var filterOptions = [AffiliateFilter]()
    var selectedFilter : AffiliateFilter?
    var selectedFilterRow : Int?
    var token : String = ""
    var loadingView : UIView?
    var selectedRow : IndexPath?
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var lastVideocallOf: UILabel!
    @IBOutlet weak var reasons: UILabel!
    @IBOutlet weak var doctor: UILabel!
    @IBOutlet weak var viewTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewTable.tableFooterView = UIView()
        self.errorView.isHidden = true
        self.viewTable.isHidden = true
        self.previosRecordsTitle.isHidden = true
        self.emptyView.isHidden = true
        self.firstItemContainer.isHidden = true
        self.loadingView = UIViewController.displaySpinner(onView: self.view)
        
        //Get token
        if let token : String = UserDefaults.standard.value(forKey: NavigationUtil.DATA.tokenKey) as? String {
           self.token = token
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showFirstItemDetail(_:)))
        firstItemContainer.addGestureRecognizer(gesture)
        
        // add pull to refresh
        pullToRefresh.attributedTitle = NSAttributedString(string: "Recargar la lista de consultas médicas")
        pullToRefresh.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        //viewTable.addSubview(pullToRefresh)
        viewTable.separatorColor = UIColor.black
        
        //create  navigation bar filter button
        let filterButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(filter))
        self.navigationItem.rightBarButtonItem = filterButton
        
        // Load the sample data.
        loadMedicalRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedRow = self.selectedRow {
            self.viewTable.deselectRow(at: selectedRow, animated: false)
            self.selectedRow = nil
        }
        
    }
    
    @objc func showFirstItemDetail(_ sender: Any) {
        self.selectedMedicalRecord = self.firstMedicalRecord
        self.performSegue(withIdentifier: NavigationUtil.NAVIGATE.showMedicalRecordDetail, sender: nil)
    }
    
    func setFirstItemValues(){
        if firstMedicalRecord != nil {
            self.date.text = util?.convertDate(date: self.firstMedicalRecord.videocall.date)
            self.lastVideocallOf.text = "Última consulta de " + (firstMedicalRecord.firstName)! + " " + (firstMedicalRecord.lastName)!
            self.reasons.text =  util?.parseReason(reasons: self.firstMedicalRecord.reasons!)
            self.doctor.text =  (firstMedicalRecord.videocall.doctor?.firstName)! + " " + (firstMedicalRecord.videocall.doctor?.lastName)!
         reasons.sizeToFit()
        }
    }
    
    
    @objc func filter(){
        if self.medicalRecords.count > 0 {
            let alert : UIAlertController = UIAlertController(title: "Filtrar", message: "Seleccioná el afiliado", preferredStyle: .alert)
            alert.isModalInPopover = true
            let previousFilter = self.selectedFilterRow
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250, height: 200)
            let pickerFrame = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250 , height: 200)) // CGRectMake(left, top, width, height) - left and top are like margins
            pickerFrame.tag = 555
            //set the pickers datasource and delegate
            pickerFrame.delegate = self
            pickerFrame.dataSource = self
            if selectedFilter == nil {
                pickerFrame.selectRow(0, inComponent: 0, animated: false)
            } else {
                pickerFrame.selectRow(self.selectedFilterRow!, inComponent: 0, animated: false)
            }
            vc.view.addSubview(pickerFrame)

            //Add the picker to the alert controller
            alert.setValue(vc, forKey: "contentViewController")
            
            let action1:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) { (_:UIAlertAction) in
                if previousFilter != self.selectedFilterRow {
                    self.doFilter()
                }
                alert.dismiss(animated: true, completion: {})
            }
            alert.addAction(action1)
            let action2:UIAlertAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
               alert.dismiss(animated: true, completion: {})
            }
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert : UIAlertController = UIAlertController(title: "", message: "No hay historias clínicas anteriores", preferredStyle: .alert)
            alert.isModalInPopover = true
            let actionAcept:UIAlertAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.cancel) { (_:UIAlertAction) in
                 alert.dismiss(animated: true, completion: {});
            }
            alert.addAction(actionAcept)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func doFilter(){
        if let filter = selectedFilter {
             self.filteredMedicalRecords.removeAll()
            for medicalRecord in self.medicalRecords {
                if medicalRecord.affiliateGamId == filter.affiliateGamId {
                    self.filteredMedicalRecords.append(medicalRecord)
                }
            }
        }
        if self.filteredMedicalRecords.count > 0 {
            self.firstMedicalRecord = self.filteredMedicalRecords[0]
            self.filteredMedicalRecords = Array(filteredMedicalRecords.dropFirst())
            self.setFirstItemValues()
        }
        
        self.viewTable.reloadData()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()

        let titleData =  String("\(String(describing: filterOptions[row].firstName!)) \(String(describing: filterOptions[row].lastName!))")
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String("\(String(describing: filterOptions[row].firstName!)) \(String(describing: filterOptions[row].lastName!))")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedFilter = filterOptions[row]
        self.selectedFilterRow = row
    }
    
    @objc func reload() {
        viewTable.reloadData()
        pullToRefresh.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredMedicalRecords.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MedicalRecordTableViewCell", for: indexPath)  as? MedicalRecordTableViewCell else {
            fatalError("The dequeued cell is not an instance of MedicalRecordTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let medicalRecord = filteredMedicalRecords[indexPath.row]
        cell.date.text = util?.convertDate(date: medicalRecord.videocall.date!)
        cell.name.text =  String(describing:medicalRecord.firstName!+" "+medicalRecord.lastName!)
        cell.reasons.text =  util?.parseReason(reasons: medicalRecord.reasons!)
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath
        self.selectedMedicalRecord = self.filteredMedicalRecords[indexPath.row];
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
                DispatchQueue.main.async(execute: {
                    self.errorView.isHidden = false
                    self.previosRecordsTitle.isHidden = true
                    self.viewTable.isHidden = true
                    self.firstItemContainer.isHidden = true
                    self.emptyView.isHidden = true
                })
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == 408 {
                SessionUtil.logout(vc: self)
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            // parse the data
            let parsedResult: [MedicalRecord]!
            do {
                parsedResult = try JSONDecoder().decode([MedicalRecord].self, from: data)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                UIViewController.removeSpinner(spinner: self.loadingView!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.selectedFilter = nil
                self.selectedFilterRow = nil
                self.medicalRecords = parsedResult
                if self.medicalRecords.count > 0 {
                    self.filteredMedicalRecords = Array(parsedResult.dropFirst())
                    self.firstMedicalRecord = self.medicalRecords[0]
                    self.setFirstItemValues()
                    self.filterOptions.removeAll()
                    for medicalRecord in self.medicalRecords {
                        if self.filterOptions.count == 0 {
                            self.filterOptions.append(AffiliateFilter(firstName: medicalRecord.firstName!, lastName: medicalRecord.lastName!, affiliateGamId: medicalRecord.affiliateGamId)!)
                        } else {
                            if !self.filterOptions.contains(where: { (affiliate) -> Bool in
                                affiliate.affiliateGamId == medicalRecord.affiliateGamId
                            }){
                                self.filterOptions.append(AffiliateFilter(firstName: medicalRecord.firstName!, lastName: medicalRecord.lastName!, affiliateGamId: medicalRecord.affiliateGamId)!)
                            }
                        }
                    }
                    
                    self.viewTable.reloadData()
                    self.errorView.isHidden = true
                    self.previosRecordsTitle.isHidden = false
                    self.viewTable.isHidden = false
                    self.firstItemContainer.isHidden = false
                    self.emptyView.isHidden = true
                } else {
                    self.errorView.isHidden = true
                    self.emptyView.isHidden = false
                    self.previosRecordsTitle.isHidden = true
                    self.viewTable.isHidden = true
                    self.firstItemContainer.isHidden = true 
                }
                UIViewController.removeSpinner(spinner: self.loadingView!)
              
            })
            
           
        }).resume()
    }

    
}
