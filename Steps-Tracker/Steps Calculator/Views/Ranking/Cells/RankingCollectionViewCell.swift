//
//  RankingCollectionViewCell.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 12/10/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import Lottie

class RankingCollectionViewCell: UICollectionViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var stepsButton: UIButton!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var stepsRanking: [Ranking] = []
    var distanceRanking: [Ranking] = []
    private var isStepsRanking = true
    var rankSteps = "?"
    var rankDistance = "?"
    var stepsCount = 0
    var distanceTravelled = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stepsButton.backgroundColor = Constants.AppColors.primaryColor
        self.distanceButton.backgroundColor = Constants.AppColors.unSelectedColor
        NotificationCenter.default.addObserver(self, selector: #selector(colorSchemeChanged), name: Notification.Name.ColorSchemeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorSchemeChanged), name: Notification.Name.DidPurchasedSubscription, object: nil)
    }
    
    @objc private func colorSchemeChanged() {
        if isStepsRanking {
            self.stepsButton.backgroundColor = Constants.AppColors.primaryColor
            self.distanceButton.backgroundColor = Constants.AppColors.unSelectedColor
        } else {
            self.stepsButton.backgroundColor = Constants.AppColors.unSelectedColor
            self.distanceButton.backgroundColor = Constants.AppColors.primaryColor
        }
    }
    
    func setupCell(stepsRank: [Ranking], distanceRank: [Ranking], rankStepString: String, rankDistanceString: String, steps: Int, distance: String) {
        
        self.stepsRanking = stepsRank
        self.distanceRanking = distanceRank
        self.rankSteps = rankStepString
        self.rankDistance = rankDistanceString
        self.stepsCount = steps
        self.distanceTravelled = distance
        self.setupDelegateAndDataSource()
        self.tableView.reloadData()
        self.updateLbls()
    }
    
    //MARK:- IBActions
    @IBAction func stepsTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            self.stepsButton.backgroundColor = Constants.AppColors.primaryColor
            self.distanceButton.backgroundColor = Constants.AppColors.unSelectedColor
            self.isStepsRanking = true
            self.tableView.reloadData()
            self.updateLbls()
        }
    }
    
    @IBAction func distanceTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            self.stepsButton.backgroundColor = Constants.AppColors.unSelectedColor
            self.distanceButton.backgroundColor = Constants.AppColors.primaryColor
            self.isStepsRanking = false
            self.tableView.reloadData()
            self.updateLbls()
        }
    }
    
    //MARK:- Helper Methods
    func setupDelegateAndDataSource() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func updateLbls() {
        
        if self.isStepsRanking {
            self.nameLbl.text = dataManager.user?.userName
            
            self.pointsLbl.text = String(format: "%d",self.stepsCount)
            
            self.rankLbl.text = self.rankSteps
        } else {
            self.nameLbl.text = dataManager.user?.userName
            self.pointsLbl.text = self.distanceTravelled
            
            self.rankLbl.text = self.rankDistance
        }
    }
}

extension RankingCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableViewCell") as? RankingTableViewCell
        var rank: Ranking!
        if indexPath.row > 2 {
            cell?.animationView.isHidden = true
            
        } else {
            cell?.animationView.isHidden = false
            if indexPath.row == 0 {
                cell?.animationView.animation = Animation.named("starGold")
            } else if indexPath.row == 1 {
                cell?.animationView.animation = Animation.named("starSilver")
            } else {
                cell?.animationView.animation = Animation.named("starMetal")
            }
            
            cell?.animationView.loopMode = .loop
            cell?.animationView.play()
        }
        if self.isStepsRanking {
            if indexPath.row < stepsRanking.count {
                rank = stepsRanking[indexPath.row]
                cell?.pointsLbl.text = String(format: "%d", rank.steps)
            } else {
                cell?.pointsLbl.text = "-"
                cell?.rankLbl.text = "-"
                cell?.nameLbl.text = "-"
            }
            if let rankStepsInt = Int(rankSteps) {
                if rankStepsInt == (indexPath.row + 1) {
                    cell?.topRankersView.isHidden = false
                } else {
                    cell?.topRankersView.isHidden = true
                }
            } else {
                cell?.topRankersView.isHidden = true
            }
        } else {
            if indexPath.row < distanceRanking.count {
                rank = distanceRanking[indexPath.row]
                cell?.pointsLbl.text = rank.distance
            } else {
                cell?.pointsLbl.text = "-"
                cell?.rankLbl.text = "-"
                cell?.nameLbl.text = "-"
            }
            if let rankDistanceInt = Int(rankDistance) {
                
                if rankDistanceInt == (indexPath.row + 1) {
                    cell?.topRankersView.isHidden = false
                } else {
                    cell?.topRankersView.isHidden = true
                }
            } else {
                cell?.topRankersView.isHidden = true
            }
        }
        if rank != nil {
            cell?.nameLbl.text = rank.name
        }
        cell?.rankLbl.text = String(format: "%d", (indexPath.row + 1))
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 36
    }
}
