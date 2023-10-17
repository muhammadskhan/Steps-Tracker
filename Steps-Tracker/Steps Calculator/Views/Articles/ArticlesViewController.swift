//
//  ArticlesViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 04/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds

class ArticlesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var articles: [Article] = []
    private var interstitial: GADInterstitial!
//    private lazy var upSellView: UpSellView = {
//        let upSellView = Bundle.main.loadNibNamed("UpSellView", owner: self, options: nil)?.first as! UpSellView
//        upSellView.source = "Articles"
//        upSellView.translatesAutoresizingMaskIntoConstraints = false
//        upSellView.setBlurAlpha(alpha: 0.975)
//        return upSellView
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !dataManager.isMonthlySubsActive {
            requestIDFA()
        }
    }
    
    private func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                
                self.loadAd()
            })
        } else {
            loadAd()
        }
    }
    
    private func loadAd() {
        if !dataManager.isMonthlySubsActive {
            interstitial = GADInterstitial(adUnitID: Constants.interstitialAdUnitID)
            interstitial.delegate = self
            let request = GADRequest()
            interstitial.load(request)
        }
    }
    
    private func presentAd() {
        if !dataManager.isMonthlySubsActive {
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
    }
    
//    @objc private func didPurchasedSubscription() {
//        if !dataManager.isMonthlySubsActive {
//            self.view.addSubview(self.upSellView)
//            self.upSellView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
//            self.upSellView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
//            self.upSellView.delegate = self
//            self.upSellView.center = self.view.center
//        } else {
//            self.upSellView.removeFromSuperview()
//        }
//    }
    
    private func getArticles() {
        SVProgressHUD.show()
        GetArticles().get { (res) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.articles = res ?? []
                self.tableView.reloadData()
            }
        } failure: { (err) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                Alert.showAlert(on: self, with: Constants.appName, message: err ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
}

extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell") as! ArticlesTableViewCell
        cell.titleLbl.text = articles[indexPath.row].title
        cell.descLbl.text = articles[indexPath.row].desc
        cell.thumbnail.sd_setImage(with: URL(string: articles[indexPath.row].imageLink), completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openWebView(pageTitle: articles[indexPath.row].title, webLink: articles[indexPath.row].webLink)
    }
    
    private func openWebView(pageTitle: String, webLink: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.pageTitle = "Article"
        vc.selectedWebUrl = webLink
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArticlesViewController: UpSellViewDelegate {
    func currentViewController() -> UIViewController {
        return self
    }
}

extension ArticlesViewController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        presentAd()
    }
}
