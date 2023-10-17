//
//  FeedbackViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 18/01/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var reviewTextView: CustomTextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let userName = dataManager.user?.userName {
            self.userNameLbl.text = String(format: "Hi %@", userName)
        }
        logoImageView.image = Constants.Icons.logo
        reviewTextView.setBorder(color: .gray, width: 1.0, cornerRadius: 4.0)
        submitButton.setTitleColor(Constants.AppColors.primaryColor, for: .normal)
        submitButton.setBorder(color: Constants.AppColors.primaryColor, width: 2.0, cornerRadius: 4.0)
        cancelButton.setTitleColor(Constants.AppColors.primaryColor, for: .normal)
        cancelButton.setBorder(color: Constants.AppColors.primaryColor, width: 2.0, cornerRadius: 4.0)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func submitTapped(_ sender: Any) {
        
        fsManager.sendFeedback(review: reviewTextView.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
