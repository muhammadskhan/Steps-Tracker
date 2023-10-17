//
//  PurchasesManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 14/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import Foundation
import Purchases

let purchasesManager = PurchasesManager.shared

class PurchasesManager: NSObject {
    
    static let shared = PurchasesManager()
    
    private override init() {
        
    }
    
    func configureSDK() {
        Purchases.debugLogsEnabled = true
        guard let userId = dataManager.user?.userId, userId.count > 0 else {
            Purchases.configure(withAPIKey: Constants.purchasesApiKey)
            return
        }
        Purchases.configure(withAPIKey: Constants.purchasesApiKey, appUserID: userId)
    }
    
    func updateUserId(userId: String, completion: FSHandler<Purchases.PurchaserInfo>? = nil) {
        Purchases.shared.identify(userId) { (purchaserInfo, error) in
            if error == nil {
                completion?(purchaserInfo, nil)
            } else {
                completion?(purchaserInfo, FirebaseError(error))
            }
        }
    }
    
    func getPurchaseInfo(completion: @escaping FSHandler<Purchases.PurchaserInfo>) {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if error == nil {
                if let purchaserInfo = purchaserInfo {
                    if purchaserInfo.entitlements[Constants.proEntitlementIdentifier]?.isActive == true {
                        dataManager.isMonthlySubsActive = true
                    } else {
                        dataManager.isMonthlySubsActive = false
                    }
                }
                completion(purchaserInfo, nil)
            } else {
                completion(purchaserInfo, FirebaseError(error))
            }
        }
    }
    
    func fetchOfferings(completion: @escaping FSHandler<[Purchases.Package]>) {
        Purchases.shared.offerings { (offerings, error) in
            if let packages = offerings?.current?.availablePackages {
                // Display packages for sale
                completion(packages, nil)
            } else {
                completion(nil, FirebaseError(error))
            }
        }
    }
    
    func makePurchase(package: Purchases.Package, completion: @escaping FSHandler<Bool>) {
        Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
            if let purchaserInfo = purchaserInfo {
                if purchaserInfo.entitlements[Constants.proEntitlementIdentifier]?.isActive == true {
                    // Unlock that great "pro" content
                    dataManager.isMonthlySubsActive = true
                    NotificationCenter.default.post(name: Notification.Name.DidPurchasedSubscription, object: nil)
                    completion(true,nil)
                } else {
                    dataManager.isMonthlySubsActive = false
                    completion(false,nil)
                }
            } else {
                completion(false,FirebaseError(error))
            }
        }
    }
    
    func restorePurchase( completion: @escaping FSHandler<Bool>) {
        Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            //... check purchaserInfo to see if entitlement is now active
            if let purchaserInfo = purchaserInfo {
                if purchaserInfo.entitlements[Constants.proEntitlementIdentifier]?.isActive == true {
                    // Unlock that great "pro" content
                    dataManager.isMonthlySubsActive = true
                    NotificationCenter.default.post(name: Notification.Name.DidPurchasedSubscription, object: nil)
                    completion(true,nil)
                } else {
                    dataManager.isMonthlySubsActive = false
                    completion(false,nil)
                }
            } else {
                completion(false,FirebaseError(error))
            }
        }
    }
}
