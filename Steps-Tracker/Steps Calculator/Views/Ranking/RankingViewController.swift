//
//  RankingViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 07/10/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import SVProgressHUD
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds

class RankingViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    //MARK:- Properties
    private var todayStepsRanking: [Ranking] = []
    private var todayDistanceRanking: [Ranking] = []
    private var yesterdayStepsRanking: [Ranking] = []
    private var yesterdayDistanceRanking: [Ranking] = []
    private var isStepsRanking = true
    private var todayRankSteps = "?"
    private var todayRankDistance = "?"
    private var yesterdayRankSteps = "?"
    private var yesterdayRankDistance = "?"
    private var todaySteps = 0
    private var todayDistance = ""
    private var yesterdaySteps = 0
    private var yesterdayDistance = ""
    private var shouldDisplayLoadingView = true
    private var interstitial: GADInterstitial!
    
    //MARK:- ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .right, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getTopTenRanks()
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
            interstitial = GADInterstitial(adUnitID: Constants.rankingInterstitialAdUnitID)
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
    
    //MARK:- Helper Methods
    func getTopTenRanks() {
        
        if shouldDisplayLoadingView {
            SVProgressHUD.show(withStatus: "Loading...")
            shouldDisplayLoadingView = false
        }
        
        fsManager.getTopTenStepsRank { (ranks, error) in
            
            if error == nil {
                self.todayStepsRanking = ranks ?? []
                if let index = ranks?.firstIndex(where: {$0.email == dataManager.user?.userEmail}) {
                    self.todayRankSteps = String(format: "%d", (index + 1))
                    //                        self.rankLbl.text = self.rankSteps
                }
                fsManager.getYesterdayTopTenStepsRank { (yesterdayRanks, err) in
                    
                    DispatchQueue.main.async { [weak self] in
                        SVProgressHUD.dismiss()
                        if err == nil {
                            self?.yesterdayStepsRanking = yesterdayRanks ?? []
                            if let index = yesterdayRanks?.firstIndex(where: {$0.email == dataManager.user?.userEmail}) {
                                self?.yesterdayRankSteps = String(format: "%d", (index + 1))
                                //                        self.rankLbl.text = self.rankSteps
                            }
                            self?.collectionView.reloadData()
                        } else {
                            Alert.showAlert(on: self, with: Constants.appName, message: "An error occurred while processing your request.")
                        }
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    SVProgressHUD.dismiss()
                    Alert.showAlert(on: self, with: Constants.appName, message: "An error occurred while processing your request.")
                }
            }
        }
        
        fsManager.getTopTenDistanceRank { (ranks, error) in
            
            if error == nil {
                
                self.todayDistanceRanking = ranks ?? []
                if let index = ranks?.firstIndex(where: {$0.email == dataManager.user?.userEmail}) {
                    self.todayRankDistance = String(format: "%d", (index + 1))
                }
                fsManager.getYesterdayTopTenDistanceRank { (yesterdayRanks, err) in
                    DispatchQueue.main.async { [weak self] in
                        SVProgressHUD.dismiss()
                        if err == nil {
                            self?.yesterdayDistanceRanking = yesterdayRanks ?? []
                            if let index = yesterdayRanks?.firstIndex(where: {$0.email == dataManager.user?.userEmail}) {
                                self?.yesterdayRankDistance = String(format: "%d", (index + 1))
                      
                            }
                            self?.collectionView.reloadData()
                        } else {
                            Alert.showAlert(on: self, with: Constants.appName, message: "An error occurred while processing your request.")
                        }
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    SVProgressHUD.dismiss()
                    Alert.showAlert(on: self, with: Constants.appName, message: "An error occurred while processing your request.")
                }
            }
        }
        
        fsManager.getUserRankInfoForYesterday { (rank, error) in
            
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    if let ranking = rank {
                        self?.yesterdaySteps = ranking.steps
                        self?.yesterdayDistance = ranking.distance
                        self?.setTodayDistanceAndSteps()
                    }
                } else {
                    self?.setTodayDistanceAndSteps()
                }
            }
        }
    }
    
    private func setTodayDistanceAndSteps() {
        self.todaySteps = dataManager.healthKitSteps
        if settingsManager.isDistanceInMiles {
            let distance = self.convertToMiles(meters: dataManager.healthKitDistance).convertToString()
            self.todayDistance = distance
        } else {
            let distance = self.convertToKM(meters: dataManager.healthKitDistance).convertToString()
            self.todayDistance = distance
        }
        self.collectionView.reloadData()
    }
    
    private func convertToMiles(meters: Int) -> Float {
        
        return (Float(meters)/1609.344)
    }
    
    private func convertToKM(meters: Int) -> Float {
        
        return (Float(meters)/1000)
    }
}

extension RankingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankingCollectionViewCell", for: indexPath) as! RankingCollectionViewCell
        if indexPath.item == 0 {
            cell.setupCell(stepsRank: yesterdayStepsRanking, distanceRank: yesterdayDistanceRanking, rankStepString: yesterdayRankSteps, rankDistanceString: yesterdayRankDistance, steps: self.yesterdaySteps, distance: self.yesterdayDistance)
        } else {
            cell.setupCell(stepsRank: todayStepsRanking, distanceRank: todayDistanceRanking, rankStepString: todayRankSteps, rankDistanceString: todayRankDistance, steps: self.todaySteps, distance: self.todayDistance)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankingCollectionViewCell", for: indexPath) as! RankingCollectionViewCell
        cell.setupDelegateAndDataSource()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height: CGFloat = 506
        let width = self.view.frame.size.width - 40
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if let cell = self.collectionView.visibleCells.first {
            if let indexPath = self.collectionView.indexPath(for: cell) {
                if indexPath.item == 0 {
                    self.dateLbl.text = "Yesterday"
                } else {
                    self.dateLbl.text = "Today"
                }
            }
        }
    }
}

extension RankingViewController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        presentAd()
    }
}
