//
//  CalendarCell.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 09/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import JTAppleCalendar
import KDCircularProgress

class CalendarCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var progressBar: KDCircularProgress!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
