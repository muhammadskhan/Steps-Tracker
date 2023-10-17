//
//  RankingTableViewCell.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 07/10/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import Lottie

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var rankLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var topRankersView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
