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
    @IBOutlet weak var anamnesis: UILabel!
    @IBOutlet weak var doctor: UILabel!
    
    
    var detail:MedicalRecord!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        date.text =  util?.convertDate(date: detail.videocall.date!)
        name.text = "Última consulta de \(detail.firstName!) \(detail.lastName!)"
        recommendation.text = String(describing: detail.recommendation)
        reasons.text = util?.parseReason(reasons: detail.reasons!)
        doctor.text = (detail.videocall.doctor?.firstName)! + " " + (detail.videocall.doctor?.lastName)!
        anamnesis.text = detail.anamnesis
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
