//
//  WebViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 04/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class WebViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var selectedWebUrl: String!
    var pageTitle: String!
    var onBack: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLbl.text = self.pageTitle
        loadWebView()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        onBack?()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        SVProgressHUD.show()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        SVProgressHUD.dismiss()
    }
    
    //MARK:- Helper Mehtods
    func loadWebView() {
        
        if let url = URL(string: selectedWebUrl) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
