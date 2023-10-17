//
//  PaywallViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 22/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import UIKit
import Purchases
import SVProgressHUD
import FirebaseAnalytics

class PaywallViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var strikethroughLbl: UILabel!
    @IBOutlet weak var discountedPriceLbl: UILabel!
    
    var source = ""
    private var dataSource: [PaywallDataSource] = [PaywallDataSource(desc: "Graph history of steps for each day.", icon: Constants.Icons.greenCheck),PaywallDataSource(desc: "Seven exciting color theme for App.", icon: Constants.Icons.greenCheck),PaywallDataSource(desc: "Set color to widget to match it with your home screen.", icon: Constants.Icons.greenCheck),PaywallDataSource(desc: "Seven different App Icons.", icon: Constants.Icons.greenCheck),PaywallDataSource(desc: "No-Ads.", icon: Constants.Icons.greenCheck)]
    
    private var packages: [Purchases.Package] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        strikethroughLbl.strikeThrough(true)
        Analytics.logEvent("PaywallScreenPresented_\(source)", parameters: nil)
        getOffers()
        getPircingInfo()
        
    }

    @IBAction func subscribeNowTapped(_ sender: Any) {
        if let package = packages.first {
            SVProgressHUD.show()
            purchasesManager.makePurchase(package: package) { (success, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    Alert.showAlert(on: self, with: Constants.appName, message: error?.errorDescription ?? "")
                } else {
                    Analytics.logEvent("Buy_Subscription_\(self.source)", parameters: nil)
                }
            }
        } else {
            Alert.showAlert(on: self, with: Constants.appName, message: "Coming soon...")
        }
    }
    
    @IBAction func crossTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func termsOfUseTapped(_ sender: Any) {
        self.openWebView(pageTitle: "Terms of Use", webLink: Constants.termsOfUseLink)
    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        self.openWebView(pageTitle: "Privacy Policy", webLink: Constants.privacyPolicy)
    }
    
    private func openWebView(pageTitle: String, webLink: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.pageTitle = pageTitle
        vc.selectedWebUrl = webLink
        self.present(vc, animated: true, completion: nil)
    }
    
    private func getOffers() {
        purchasesManager.fetchOfferings { (packages, error) in
            if let packages = packages {
                self.packages = packages
            }
        }
    }
    
    private func getPircingInfo() {
        GetPricingInfo().get { [weak self] (pricing) in
            DispatchQueue.main.async {
                self?.discountedPriceLbl.text = pricing?.discountedPrice
                self?.strikethroughLbl.text = pricing?.price
                self?.strikethroughLbl.strikeThrough(true)
                self?.textView.text = """
        A \(pricing?.discountedPrice ?? "US$0.99/month") purchase will be applied to your iTunes account on confirmation.

        Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your iTunes account settings.
        """
            }
        } failure: { (err) in
            print(err ?? "Error")
        }

    }
}

extension PaywallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaywallTableViewCell") as! PaywallTableViewCell
        cell.iconImage.image = dataSource[indexPath.row].icon
        cell.descLbl.text = dataSource[indexPath.row].desc
        return cell
    }
}

struct PaywallDataSource {
    var desc = ""
    var icon = UIImage()
}
