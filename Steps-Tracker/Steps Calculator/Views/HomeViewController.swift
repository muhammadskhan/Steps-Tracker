//
//  HomeViewController.swift
//  Steps Calculator
//
//  Created by Haseeb Javed on 24/08/2020.1
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import KDCircularProgress
import Lottie
import CoreMotion
import FirebaseAnalytics
import FirebaseRemoteConfig
import StoreKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import SDWebImage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var promotionAppIcon: UIImageView!
    @IBOutlet weak var customPromotionView: UIView!
    @IBOutlet weak var customPromotionLabel: UILabel!
    @IBOutlet weak var stepsIcon: UIImageView!
    @IBOutlet weak var fireIcon: UIImageView!
    @IBOutlet weak var caloriesLbl: UILabel!
    @IBOutlet weak var stepsLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var totalStepsLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var progress: KDCircularProgress!
    
    @IBOutlet weak var artyClickRedContainer: UIView!
    @IBOutlet weak var chromeYellowContainer: UIView!
    @IBOutlet weak var neonBlueContainer: UIView!
    @IBOutlet weak var defaultColorContainer: UIView!
    @IBOutlet weak var neonPinkContainer: UIView!
    @IBOutlet weak var purpleDaffodilContainer: UIView!
    @IBOutlet weak var vividGreenContainer: UIView!
    @IBOutlet var lockImages: [UIImageView]!
    
    @IBOutlet weak var indicatorImage: UIImageView!
    @IBOutlet weak var goalDistanceLbl: UILabel!
    @IBOutlet weak var traveledDistanceLbl: UILabel!
    @IBOutlet weak var progressDistance: GradientProgressBar!
    @IBOutlet weak var bannerView: GADBannerView?
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var shouldStartUpdating: Bool = true
    private var startDate: Date? = nil
//    private var isTodayDate: Bool = true
    private var isSettingsVC = false
    private var isCalendarVC = false
    private var isReviewVC = false
    var viewModel: HomeViewModel?
    
    private var remoteConfig: RemoteConfig?
    
    var currentSteps: Float = 0 {
        
        didSet {
            
            self.stepsLbl.text = self.currentSteps.convertToString()
            self.caloriesLbl.text = String(format:"%d KCal",Int((Float(settingsManager.bodyWeight)/1582.5714) * currentSteps))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig?.configSettings = settings
        fetchConfig()

        customPromotionView.isHidden = !dataManager.shouldShowCustomPromtion
        bannerView?.isHidden = dataManager.shouldShowCustomPromtion
        customPromotionLabel.text = dataManager.promotionText
        promotionAppIcon.sd_setImage(with: URL(string: dataManager.promotionAppIconUrl))
        
        healthKitManager.delegate = self
        viewModel = HomeViewModel(viewDelegate: self)

        //        if self.isTodayDate {
        self.updateTargetLbls()
        self.onStart()
        //        }
        self.containerView.setBorder(color: .clear, width: 0, cornerRadius: 12.0)
        if dataManager.noOfOpens == 10 || dataManager.noOfOpens == 50 || dataManager.noOfOpens == 100 {
            SKStoreReviewController.requestReview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorSchemeChanged), name: Notification.Name.ColorSchemeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorSchemeChanged), name: Notification.Name.DidPurchasedSubscription, object: nil)
        self.colorSchemeChanged()
        self.setContainerBorder()
        self.loadAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateRankData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateRankData()
    }
    
    private func fetchConfig() {
        
        // [START fetch_config_with_callback]
        remoteConfig?.fetch(completionHandler: { [weak self] (status, error) -> Void in
            guard let strongSelf = self else { return }
            if status == .success {
                strongSelf.remoteConfig?.activate { changed, error in
                    // ...
                }

                DispatchQueue.main.async {
                    dataManager.shouldShowCustomPromtion = strongSelf.remoteConfig?["shouldShowCustomPromtion"].boolValue ?? false
                    dataManager.promotionText = strongSelf.remoteConfig?["promotionText"].stringValue ?? "Download ChatGPT for iOS"
                    dataManager.promotionAppLink = strongSelf.remoteConfig?["promotionAppLink"].stringValue ?? "Download ChatGPT for iOS"
                    dataManager.promotionAppIconUrl = strongSelf.remoteConfig?["promotionAppIconUrl"].stringValue ?? "Download ChatGPT for iOS"
                    strongSelf.customPromotionView.isHidden = !dataManager.shouldShowCustomPromtion
                    strongSelf.promotionAppIcon.sd_setImage(with: URL(string: dataManager.promotionAppIconUrl))
                    strongSelf.bannerView?.isHidden = dataManager.shouldShowCustomPromtion
                    strongSelf.customPromotionLabel.text = dataManager.promotionText
                }
            }
        })
        // [END fetch_config_with_callback]
    }
    
    private func loadAd() {
        if !dataManager.isMonthlySubsActive {
            bannerView?.adUnitID = Constants.homeScreenAdUnitID
            bannerView?.rootViewController = self
            bannerView?.load(GADRequest())
        }
    }
    
    @objc func colorSchemeChanged() {
        stepsIcon.image = Constants.Icons.manWalking
        fireIcon.image = Constants.Icons.fire
        progress.progressColors = [Constants.AppColors.primaryColor, Constants.AppColors.ringGradient2nd]
        lockImages.forEach { (imageView) in
            imageView.isHidden = dataManager.isMonthlySubsActive
        }
        if dataManager.isMonthlySubsActive {
            bannerView?.isHidden = true
        }
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        
        if let image = containerView.makeSnapshot() {
            
            showActivity(image: image)
        }
        Analytics.logEvent(Constants.AnalyticEvents.sharedProgress, parameters: nil)
    }
        
    private func updateRankData() {
        fsManager.updateTodayStepsRank(steps: dataManager.healthKitSteps)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            fsManager.updateTodayDistanceRank(distance: dataManager.healthKitDistance)
        }
    }
    
    private func showActivity(image: UIImage) {
        
        // set up activity view controller
        
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [.saveToCameraRoll,.assignToContact,.openInIBooks,.print]
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func chatgptAdTapped(_ sender: Any) {
        Analytics.logEvent("CustomPromotionAdTapped", parameters: ["userId": dataManager.userId])
        guard let url = URL(string: dataManager.promotionAppLink) else {
          return //be safe
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func calendarTapped(_ sender: Any) {
        
        isSettingsVC = false
        isCalendarVC = true
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController
        vc?.delegate = self
        vc?.modalPresentationStyle = .custom
        vc?.transitioningDelegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
    
        isSettingsVC = true
        isCalendarVC = false
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let nvc = storyboard.instantiateInitialViewController() as! UINavigationController
        nvc.modalPresentationStyle = .custom
        nvc.isModalInPresentation = false
        nvc.transitioningDelegate = self
        let settingsVC = nvc.topViewController as! SettingsViewController
        settingsVC.delegate  = self
        self.present(nvc, animated: true, completion: nil)
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
    
    private func presentPaywall() {
        let paywall = UIStoryboard(name: "Paywall", bundle: nil)
        let vc = paywall.instantiateInitialViewController() as! PaywallViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.source = "Home"
        self.present(vc, animated: true, completion: nil)
    }
    
    private func setContainerBorder() {
        self.artyClickRedContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.defaultColorContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.chromeYellowContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.neonBlueContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.neonPinkContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.purpleDaffodilContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
        self.vividGreenContainer.setBorder(color: Constants.AppColors.artyClickRed, width: 0, cornerRadius: 19)
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
        colorSchemeChanged()
        updateTargetLbls()
        NotificationCenter.default.post(name: Notification.Name.ColorSchemeChanged, object: nil)
    }
    
    func showFeedbackController() {
        
        isReviewVC = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension HomeViewController: HomeUIUpdatesDelegate {
    
    func showCustomHealthKitPopup() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomHealthKitPopup") as! CustomHealthKitPopup
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func updateStepsUI(steps: Steps, animation: Bool) {
        
        self.currentSteps = Float(steps.todaysStepTaken)
        var realSteps = steps
        realSteps.percentage = Float(Double(realSteps.todaysStepTaken)/Double(realSteps.stepsGoal)) * 100
        let firstValue: Float = Float((270.0 / Double(realSteps.stepsGoal)))
        let angle = firstValue * Float(realSteps.todaysStepTaken)
        if animation {
            if angle < 270 {
                progress.animate(fromAngle: 0, toAngle: Double(angle), duration: 1) { (completed) in
                    
                }
            } else {
                
                progress.animate(fromAngle: 0, toAngle: 270, duration: 1) { (completed) in
                    
                }
            }
        } else {
            
            if angle < 270 {
                
                progress.angle = Double(angle)
            } else {
                
                progress.angle = 270
            }
        }
        
        //Updating meter image
        if realSteps.percentage >= 93 {
            
            indicatorImage.image = Constants.Icons.indicator90
        } else if realSteps.percentage >= 81.5 {
            
            indicatorImage.image = Constants.Icons.indicator80
        } else if realSteps.percentage >= 70.5 {
            
            indicatorImage.image = Constants.Icons.indicator70
        } else if realSteps.percentage >= 59 {
            
            indicatorImage.image = Constants.Icons.indicator60
        } else if realSteps.percentage >= 50 {
            
            indicatorImage.image = Constants.Icons.indicator50
        } else if realSteps.percentage >= 38.75 {
            
            indicatorImage.image = Constants.Icons.indicator40
        } else if realSteps.percentage >= 27 {
            
            indicatorImage.image = Constants.Icons.indicator30
        } else if realSteps.percentage >= 16.25 {
            
            indicatorImage.image = Constants.Icons.indicator20
        } else if realSteps.percentage >= 5 {
            
            indicatorImage.image = Constants.Icons.indicator10
        } else {
            
            indicatorImage.image = Constants.Icons.indicator0
        }
    }
    
    func updateDistanceProgressBar(distance: Distance) {
        
        self.updateDistanceLbl(distance: distance)
        self.progressDistance.progress = distance.percentage / 100
    }
    
    func convertToMiles(meters: Int) -> Float {
        
        return (Float(meters)/1609.344)
    }
    
    func convertToKM(meters: Int) -> Float {
        
        return (Float(meters)/1000)
    }

    
    func updateDistanceLbl(distance: Distance) {
        
        if settingsManager.isDistanceInMiles {
            
            let distance = convertToMiles(meters: distance.distanceTraveled).convertToString()
            self.traveledDistanceLbl.text = String(format: "Distance - %@ mi", distance)
            let goalDistanceStr = convertToMiles(meters: settingsManager.distanceTarget).convertToString()
            self.goalDistanceLbl.text = String(format: "Goal %@ mi", goalDistanceStr)
        } else {
            
            let distance = convertToKM(meters: distance.distanceTraveled).convertToString()
            self.traveledDistanceLbl.text = String(format: "Distance - %@ km", distance)
            let goalDistanceStr = convertToKM(meters: settingsManager.distanceTarget).convertToString()
            self.goalDistanceLbl.text = String(format: "Goal %@ km", goalDistanceStr)
        }
    }
}

extension HomeViewController: TargetUpdated {
    
    func askForHealthKitPermissions() {
        
//        if self.isTodayDate {
            
            viewModel?.authorizeHealthKit()
//        }
    }
    
    func targetDidUpdate() {
        
//        if self.isTodayDate {
            self.updateTargetLbls()
            
//        }
    }
    
    func updateTargetLbls() {
        viewModel?.authorizeHealthKit()
        let goalStepsStr = Float(settingsManager.stepsTarget).convertToString()
        self.totalStepsLbl.text = String(format: "Goal %@", goalStepsStr)
        if settingsManager.isDistanceInMiles {
            let goalDistanceStr = convertToMiles(meters: settingsManager.distanceTarget).convertToString()
            self.goalDistanceLbl.text = String(format: "Goal %@ mi", goalDistanceStr)
        } else {
            let goalDistanceStr = convertToKM(meters: settingsManager.distanceTarget).convertToString()
            self.goalDistanceLbl.text = String(format: "Goal %@ km", goalDistanceStr)
        }
    }
}

extension HomeViewController {
    
    private func onStart() {
        
        if shouldStartUpdating {
            startDate = Date()
            checkAuthorizationStatus()
            startUpdating()
        }
    }
    
    
    private func startUpdating() {
        
        if CMPedometer.isStepCountingAvailable() {
            startCountingSteps()
        }
    }
    
    private func checkAuthorizationStatus() {
        switch CMMotionActivityManager.authorizationStatus() {
        case CMAuthorizationStatus.denied: break
        
        default:break
        }
    }
    
    private func startCountingSteps() {
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                var steps = Steps(stepsGoal: settingsManager.stepsTarget, date: Date())
                steps.todaysStepTaken = Int(truncating: pedometerData.numberOfSteps) + dataManager.healthKitSteps
                steps.percentage = Float(Double(steps.todaysStepTaken)/Double(steps.stepsGoal)) * 100
                self?.updateStepsUI(steps: steps, animation: false)
                
                var distance = Distance(goal: settingsManager.distanceTarget, date: Date())
                distance.distanceTraveled = Int(truncating: pedometerData.numberOfSteps) + dataManager.healthKitDistance
                distance.percentage = Float(Double(distance.distanceTraveled)/Double(distance.goal)) * 100
                self?.updateDistanceProgressBar(distance: distance)
            }
        }
    }
}

extension HomeViewController: UIPresentationControllerDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let blurEffectStyle = UIBlurEffect.Style.dark
        self.view.alpha = 0.5
        presented.isModalInPresentation = false
        return UIPresentationControllerExtension(fromDirection: .bottom, blurEffectStyle: blurEffectStyle, presentedViewController: presented, delegate: self)
    }
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        var height: CGFloat = 490
        
        if isSettingsVC {
            
            height = self.view.frame.height / (5/4)
        } else if isCalendarVC {
            
            height = self.view.frame.height / (5/4)
        } else if isReviewVC {
            
            return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: containerViewFrame.width, height: height + 120))
        } else {
            
            return CGRect(origin: CGPoint(x: 16, y: ((containerViewFrame.height/2) - (height/2))), size: CGSize(width: containerViewFrame.width - 32, height: height))
        }
        return CGRect(origin: CGPoint(x: 0, y: containerViewFrame.height - (height - 20)), size: CGSize(width: containerViewFrame.width, height: height ))
    }
    
    func didDismiss() {
        
        self.view.alpha = 1.0
    }
}

extension HomeViewController: HealthKitDelegate {
    
    func didRecieveStepsData() {
        
        DispatchQueue.main.async { [weak self] in
            //            if self.isTodayDate {
            self?.onStart()
            //        }
        }
//
    }
    
    func didRecieveDistanceData() {
        
        DispatchQueue.main.async { [weak self] in
//        if self.isTodayDate {
            self?.onStart()
//        }
        }
    }
}

extension HomeViewController: CalendarViewControllerDelegate {
    
    func dateDidSelected(date: Date) {
        shouldStartUpdating = false
        viewModel?.fetchStepsCountFor(date: date)
        viewModel?.getDistanceFor(date: date, { (res) in
            
            DispatchQueue.main.async { [weak self] in
                
                var distance = Distance(goal: settingsManager.distanceTarget, date: Date())
                distance.distanceTraveled = Int(res)
                distance.percentage = Float(Double(distance.distanceTraveled)/Double(distance.goal)) * 100
                self?.updateDistanceProgressBar(distance: distance)
            }
        })
    }
}

extension HomeViewController: CustomHealthKitPopupDelegate {
    
    func didTappedAllow() {
        
        healthKitManager.requestDataAccess { (error) in
            if error == nil {
                healthKitManager.observeHealthKitInBackground(UIApplication.shared)
                DispatchQueue.main.async { [weak self] in
                    
                    self?.viewModel?.authorizeHealthKit()
                }
            }
        }
    }
}
