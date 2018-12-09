//
//  NewsViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 13/09/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit
import WebKit

class NewsViewController : UIViewController {
    
    @IBOutlet weak var webview: WKWebView!
    var loadingView : UIView?
    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingView = UIViewController.displaySpinner(onView: self.view)
        let url  = URL(string: "http://www.ayudamedica.net/category/noticias/")
        webview.load(URLRequest(url: url!))
        webview.allowsBackForwardNavigationGestures = true
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
    }
    
    @objc func timeout(){
        DispatchQueue.main.async(execute: {
            UIViewController.removeSpinner(spinner: self.loadingView!)
        })
        timer?.invalidate()
    }
}
