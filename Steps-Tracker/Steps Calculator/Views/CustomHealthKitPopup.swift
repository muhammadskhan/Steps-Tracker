//
//  CustomHealthKitPopup.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 18/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit

protocol CustomHealthKitPopupDelegate: AnyObject {
    
    func didTappedAllow()
}
class CustomHealthKitPopup: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var allowButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: CustomHealthKitPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logoImageView.image = Constants.Icons.logo
        allowButton.setTitleColor(Constants.AppColors.primaryColor, for: .normal)
        allowButton.setBorder(color: Constants.AppColors.primaryColor, width: 2.0, cornerRadius: 4.0)
        cancelButton.setTitleColor(Constants.AppColors.primaryColor, for: .normal)
        cancelButton.setBorder(color: Constants.AppColors.primaryColor, width: 2.0, cornerRadius: 4.0)
    }
    
    @IBAction func allowTapped(_ sender: Any) {
        
        self.dismiss(animated: true) {
            self.delegate?.didTappedAllow()
        }
        
    }

    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

}
