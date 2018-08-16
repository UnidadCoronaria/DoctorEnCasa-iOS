//
//  MedicalRecordDetailViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin on 2/4/18.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit

class MedicalRecordDetailViewController: UIViewController {

    
    //MARK variables
    let util = Util()
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var reasons: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var recommendation: UILabel!
    
    var detail:MedicalRecord!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        date.text =  util?.convertDate(date: detail.videocall.date!)
        name.text = String(describing: detail.firstName!)
        recommendation.text = String(describing: detail.recommendation)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
