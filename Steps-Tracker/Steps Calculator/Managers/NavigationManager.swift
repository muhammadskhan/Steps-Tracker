//
//  NavigationManager.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 09/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit

let navigationManager = NavigationManager.shared

class NavigationManager: NSObject {
    
    static let shared = NavigationManager()
    
    private override init() {
        
    }
}

extension NavigationManager {
    
    func showCustomLaunch() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomLaunchViewController")
        self.showViewControllerOnWindow(vc)
    }
    
    func showInitialScreen(_ isLoggedIn: Bool) {
        if isLoggedIn {
            self.showHomeScreen()
        } else {
            self.showAuthenticationScreen()
        }
    }
    
    func showAuthenticationScreen() {
        
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        let navigatioController = storyboard.instantiateInitialViewController() as? UINavigationController
        navigatioController?.navigationBar.isHidden = true
        self.showViewControllerOnWindow(navigatioController)
    }
    
    func showHomeScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
        self.showViewControllerOnWindow(tabBarController)
    }
}

private extension NavigationManager {
    func showViewControllerOnWindow(_ viewController: UIViewController?) {
        
        var keyWindow: UIWindow?
        
        // iOS13 or later
        if #available(iOS 13.0, *) {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            keyWindow = sceneDelegate?.window
        // iOS12 or earlier
        } else {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            keyWindow = appDelegate?.window
        }
        
        if let window = keyWindow, let rootViewController = viewController {
  
            window.rootViewController = rootViewController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}
