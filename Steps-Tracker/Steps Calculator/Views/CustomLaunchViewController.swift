//
//  CustomLaunchViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 13/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
#if canImport(WidgetKit)
import WidgetKit
import FirebaseAnalytics
#endif

class CustomLaunchViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var topImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.logo.image = Constants.Icons.logo
        self.bottomImage.image = Constants.Icons.bottom
        self.topImage.image = Constants.Icons.top
        self.zoomIn(animatingView: logo, duration: 2.0)
        
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.getCurrentConfigurations { (result) in
                
                switch result {
                    
                case .success(let info):
                    
                    if info.count > 0 {
                        if !dataManager.widgetAddedEventLogged {
                            dataManager.widgetAddedEventLogged = true
                            Analytics.logEvent(Constants.AnalyticEvents.widgetAdded, parameters: nil)
                        }
                    }
                case .failure(_):
                    break
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    

    func zoomIn(animatingView: UIView,duration: TimeInterval = 0.2) {
        animatingView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            animatingView.transform = .init(scaleX: 5.0, y: 5.0)
            self.bottomImage.alpha = 0
            self.topImage.alpha = 0
            animatingView.alpha = 0
            }) { (animationCompleted: Bool) -> Void in
            navigationManager.showInitialScreen(dataManager.isLoggedIn())
        }
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
