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
    override func viewDidLoad() {
        super.viewDidLoad()
        let url  = URL(string: "http://www.ayudamedica.net/category/noticias/")
        webview.load(URLRequest(url: url!))
        webview.allowsBackForwardNavigationGestures = true
    }
}
