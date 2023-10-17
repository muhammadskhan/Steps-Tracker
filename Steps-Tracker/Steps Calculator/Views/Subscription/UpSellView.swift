//
//  UpSellView.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 21/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import UIKit

protocol UpSellViewDelegate: class {
    func currentViewController() -> UIViewController
}

class UpSellView: UIView {

    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var proButton: UIButton!
    
    weak var delegate: UpSellViewDelegate?
    var source = ""
//     Only override draw() if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.colorSchemeChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(colorSchemeChanged), name: Notification.Name.ColorSchemeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorSchemeChanged), name: Notification.Name.DidPurchasedSubscription, object: nil)
    }
    
    @objc func colorSchemeChanged() {
        proButton.backgroundColor = Constants.AppColors.primaryColor
    }
    
    func setBlurAlpha(alpha: CGFloat) {
        blurImageView.alpha = alpha
    }
    
    private func presentPaywall() {
        let paywall = UIStoryboard(name: "Paywall", bundle: nil)
        let vc = paywall.instantiateInitialViewController() as! PaywallViewController
        vc.source = source
        vc.modalPresentationStyle = .overFullScreen
        if let delegate = delegate {
            let selfVc = delegate.currentViewController()
            selfVc.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func proTapped(_ sender: Any) {
        presentPaywall()
    }
}
