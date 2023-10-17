//
//  SettingsViewController.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 14/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
protocol TargetUpdated: class {
    
    func targetDidUpdate()
    func askForHealthKitPermissions()
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var widgetImageView: UIImageView!
    @IBOutlet weak var stepsMinusBtn: UIButton!
    @IBOutlet weak var stepsPlusBtn: UIButton!
    @IBOutlet weak var distanceMinusBtn: UIButton!
    @IBOutlet weak var distancePlusBtn: UIButton!
    @IBOutlet weak var weightMinusBtn: UIButton!
    @IBOutlet weak var weightPlusBtn: UIButton!
    @IBOutlet weak var shortNameContainer: GradientView!
    @IBOutlet weak var artyClickRedContainer: UIView!
    @IBOutlet weak var chromeYellowContainer: UIView!
    @IBOutlet weak var neonBlueContainer: UIView!
    @IBOutlet weak var defaultColorContainer: UIView!
    @IBOutlet weak var neonPinkContainer: UIView!
    @IBOutlet weak var purpleDaffodilContainer: UIView!
    @IBOutlet weak var vividGreenContainer: UIView!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var distanceUnitLbl: UILabel!
    @IBOutlet weak var stepsTargetLbl: UILabel!
    @IBOutlet weak var distanceTargetLbl: UILabel!
    @IBOutlet weak var milesGradientView: GradientView!
    @IBOutlet weak var kmGradientView: GradientView!
    @IBOutlet weak var userShortNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var healthKitStatusBtn: UIButton!
    @IBOutlet weak var healthKitStatusLbl: UILabel!
    @IBOutlet var lockImages: [UIImageView]!
    
    weak var delegate: TargetUpdated? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.updateStatusButton()
        self.weightLbl.text = String(format: "%d kg", settingsManager.bodyWeight)
        self.stepsTargetLbl.text = Float(settingsManager.stepsTarget).convertToString()
        self.milesGradientView.isHidden = !settingsManager.isDistanceInMiles
        self.kmGradientView.isHidden = settingsManager.isDistanceInMiles
        self.updateDistanceLbl()
        self.userNameLbl.text = dataManager.user?.userName
        self.userShortNameLbl.text = dataManager.user?.userName.getAcronyms()
        self.distanceUnitLbl.text = settingsManager.isDistanceInMiles ? "mi" : "km"
        self.setContainerBorder()
        didPurchasedSubscription()
        NotificationCenter.default.addObserver(self, selector: #selector(didPurchasedSubscription), name: Notification.Name.DidPurchasedSubscription, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.targetDidUpdate()
    }
    
    private func setContainerBorder() {
        self.artyClickRedContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.defaultColorContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.chromeYellowContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.neonBlueContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.neonPinkContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.purpleDaffodilContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.vividGreenContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.stepsMinusBtn.setImage(Constants.Icons.minus, for: .normal)
        self.stepsPlusBtn.setImage(Constants.Icons.plus, for: .normal)
        self.distanceMinusBtn.setImage(Constants.Icons.minus, for: .normal)
        self.distancePlusBtn.setImage(Constants.Icons.plus, for: .normal)
        self.weightMinusBtn.setImage(Constants.Icons.minus, for: .normal)
        self.weightPlusBtn.setImage(Constants.Icons.plus, for: .normal)
        self.widgetImageView.image = Constants.Icons.widget
        self.healthKitStatusBtn.tintColor = Constants.AppColors.primaryColor
        self.shortNameContainer.startColor = Constants.AppColors.primaryColor
        self.shortNameContainer.endColor = Constants.AppColors.ringGradient2nd
        self.logoutBtn.setImage(Constants.Icons.logout, for: .normal)
        switch sharedDataManager.appColor {
        case .artyClickRed:
            self.artyClickRedContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 2.0, cornerRadius: 19)
            break
        case .defaultColor:
            self.defaultColorContainer.setBorder(color: Constants.AppColors.defaultPink, width: 2.0, cornerRadius: 19)
            break
        case .chromeYellow:
            self.chromeYellowContainer.setBorder(color: Constants.AppColors.chromeYellow, width: 2.0, cornerRadius: 19)
            break
        case .neonBlue:
            self.neonBlueContainer.setBorder(color: Constants.AppColors.neonBlue, width: 2.0, cornerRadius: 19)
            break
        case .neonPink:
            self.neonPinkContainer.setBorder(color: Constants.AppColors.neonPink, width: 2.0, cornerRadius: 19)
            break
        case .purpleDaffodil:
            self.purpleDaffodilContainer.setBorder(color: Constants.AppColors.purpleDaffodil, width: 2.0, cornerRadius: 19)
            break
        case .vividGreen:
            self.vividGreenContainer.setBorder(color: Constants.AppColors.vividGreen, width: 2.0, cornerRadius: 19)
            break
        }
        
        NotificationCenter.default.post(name: Notification.Name.ColorSchemeChanged, object: nil)
    }
    
    @objc func didPurchasedSubscription() {
        //remove locks here.
        lockImages.forEach { (imageView) in
            imageView.isHidden = dataManager.isMonthlySubsActive
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        Analytics.logEvent("delete_account_tapped", parameters: nil)
        Alert.showAlert(on: self, withTitle: "Delete Account", message: "Are you sure you want to delete your account?") { shouldDelete in
            if shouldDelete {
                fsManager.deleteUser { result, error in
                    if error != nil {
                        Alert.showAlert(on: self, with: "Error", message: "Error deleting account")
                    } else {
                        dataManager.user = nil
                        dataManager.clearDefaults()
                        navigationManager.showAuthenticationScreen()
                    }
                }
            }
        }
    }
    
    @IBAction func shareTheApp(_ sender: Any) {
        
        showActivity()
        Analytics.logEvent(Constants.AnalyticEvents.sharedApp, parameters: nil)
    }
    
    @IBAction func minusTapped(_ sender: Any) {
    
        if sharedDataManager.stepsTarget > 1999 {
            sharedDataManager.stepsTarget -= 1000
            self.stepsTargetLbl.text = Float(settingsManager.stepsTarget).convertToString()
        }
    }
    
    @IBAction func plusTapped(_ sender: Any) {
        
        if sharedDataManager.stepsTarget < 40000 {
            sharedDataManager.stepsTarget += 1000
            self.stepsTargetLbl.text = Float(settingsManager.stepsTarget).convertToString()
        }
    }
    
    @IBAction func distanceMinusTapped(_ sender: Any) {
        
        if settingsManager.distanceTarget > 1999 {
            settingsManager.distanceTarget -= 1000
            
            self.updateDistanceLbl()
        }
    }
    
    @IBAction func distancePlusTapped(_ sender: Any) {
        
        if settingsManager.distanceTarget < 20000 {
            settingsManager.distanceTarget += 1000
            self.updateDistanceLbl()
        }
    }
    
    @IBAction func metersTapped(_ sender: Any) {
        
        settingsManager.isDistanceInMiles = true
        self.kmGradientView.isHidden = true
        self.milesGradientView.isHidden = false
        self.updateDistanceLbl()
    }
    
    @IBAction func kilometersTapped(_ sender: Any) {
        
        settingsManager.isDistanceInMiles = false
        self.milesGradientView.isHidden = true
        self.kmGradientView.isHidden = false
        self.updateDistanceLbl()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            dataManager.user = nil
            dataManager.clearDefaults()
            navigationManager.showAuthenticationScreen()
        } catch _ as NSError {
          
        }
    }
    
    
    @IBAction func askForHealthKitPermission(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        delegate?.askForHealthKitPermissions()
    }
    
    @IBAction func weightMinusTapped(_ sender: Any) {
        
        settingsManager.bodyWeight -= 1
        weightLbl.text = String(format: "%d kg", settingsManager.bodyWeight)
    }
    
    @IBAction func weightPlusTapped(_ sender: Any) {
        
        settingsManager.bodyWeight += 1
        weightLbl.text = String(format: "%d kg", settingsManager.bodyWeight)
    }
    
    @IBAction func artyClickRedTapped(_ sender: Any) {
        if !dataManager.isMonthlySubsActive {
            presentPaywall()
        } else {
            sharedDataManager.appColor = .artyClickRed
            setContainerBorder()
            appIconManager.setIcon(.artyClickRed)
        }
    }
    
    @IBAction func chromeYellowTappedTapped(_ sender: Any) {
        if !dataManager.isMonthlySubsActive {
            presentPaywall()
        } else {
            sharedDataManager.appColor = .chromeYellow
            setContainerBorder()
            appIconManager.setIcon(.chromeYellow)
        }
    }
    
    @IBAction func neonBlueTapped(_ sender: Any) {
        
        sharedDataManager.appColor = .neonBlue
        setContainerBorder()
        appIconManager.setIcon(.neonBlue)
    }
    
    @IBAction func defaultColorTapped(_ sender: Any) {
        sharedDataManager.appColor = .defaultColor
        setContainerBorder()
        appIconManager.setIcon(.classic)
    }
    
    @IBAction func neonPinkTapped(_ sender: Any) {
        if !dataManager.isMonthlySubsActive {
            presentPaywall()
        } else {
            sharedDataManager.appColor = .neonPink
            setContainerBorder()
            appIconManager.setIcon(.neonPink)
        }
    }
    
    @IBAction func purpleDaffodilTapped(_ sender: Any) {
        if !dataManager.isMonthlySubsActive {
            presentPaywall()
        } else {
            sharedDataManager.appColor = .purpleDaffodil
            setContainerBorder()
            appIconManager.setIcon(.purpleDaffodil)
        }
    }
    
    @IBAction func vividGreenTapped(_ sender: Any) {
        if !dataManager.isMonthlySubsActive {
            presentPaywall()
        } else {
            sharedDataManager.appColor = .vividGreen
            setContainerBorder()
            appIconManager.setIcon(.vividGreen)
        }
    }
    
    @IBAction func restorePurchasesTapped(_ sender: Any) {
        SVProgressHUD.show()
        purchasesManager.restorePurchase { (success, error) in
            SVProgressHUD.dismiss()
            if error != nil {
                Alert.showAlert(on: self, with: Constants.appName, message: error?.errorDescription ?? "")
            } else {
                Analytics.logEvent("Restore_Purchases", parameters: nil)
            }
        }
    }
    
    private func presentPaywall() {
        let paywall = UIStoryboard(name: "Paywall", bundle: nil)
        let vc = paywall.instantiateInitialViewController() as! PaywallViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.source = "Settings"
        self.present(vc, animated: true, completion: nil)
    }
    
    func updateStatusButton() {
        if healthKitManager.isAllowedAccess {
            healthKitStatusBtn.setImage(Constants.Icons.checked, for: .normal)
            healthKitStatusLbl.text = "Connected"
            healthKitStatusBtn.isUserInteractionEnabled = false
        } else {
            healthKitStatusBtn.setImage(Constants.Icons.forwardOpen, for: .normal)
            healthKitStatusLbl.text = "Not Connected"
            healthKitStatusBtn.isUserInteractionEnabled = true
        }
    }
    
    func convertToMiles(meters: Int) -> Float {
        
        return (Float(meters)/1609.344)
    }
    
    func convertToKM(meters: Int) -> Float {
        
        return (Float(meters)/1000)
    }
    
    func updateDistanceLbl() {
        
        if settingsManager.isDistanceInMiles {
            
            self.distanceTargetLbl.text = self.convertToMiles(meters: settingsManager.distanceTarget).convertToString()
        } else {
            
            self.distanceTargetLbl.text = self.convertToKM(meters: settingsManager.distanceTarget).convertToString()
        }
        
        self.distanceUnitLbl.text = settingsManager.isDistanceInMiles ? "mi" : "km"
    }
    
    private func showActivity() {
        
        // set up activity view controller
        let appShare = [Constants.appstoreLink]
        let activityViewController = UIActivityViewController(activityItems: appShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}
