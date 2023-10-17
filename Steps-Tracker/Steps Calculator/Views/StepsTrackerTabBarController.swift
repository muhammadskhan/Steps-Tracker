//
//  StepsTrackerTabBarController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 18/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import UIKit

class StepsTrackerTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateTabBarItems()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarItems), name: Notification.Name.ColorSchemeChanged, object: nil)
    }
    
    @objc func updateTabBarItems() {
        self.tabBar.items?[0].selectedImage = Constants.Icons.home?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].selectedImage = Constants.Icons.ranking?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].selectedImage = Constants.Icons.article?.withRenderingMode(.alwaysOriginal)
        self.tabBar.tintColor = Constants.AppColors.primaryColor
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension Notification.Name {
    static let ColorSchemeChanged = Notification.Name("ColorSchemeChanged")
    static let DidPurchasedSubscription = Notification.Name("DidPurchasedSubscription")
}

