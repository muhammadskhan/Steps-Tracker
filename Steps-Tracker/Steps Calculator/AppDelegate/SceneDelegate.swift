//
//  SceneDelegate.swift
//  Steps Calculator
//
//  Created by Haseeb Javed on 24/08/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import Firebase

#if canImport(WidgetKit)
import WidgetKit
#endif

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }

        self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        self.window?.windowScene = windowScene
        
        navigationManager.showCustomLaunch()
        
        self.window?.makeKeyAndVisible()
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        
        if #available(iOS 14.0, *) {
            
            WidgetCenter.shared.reloadTimelines(ofKind: "StepsWidget")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        if #available(iOS 14.0, *) {
            
            WidgetCenter.shared.reloadTimelines(ofKind: "StepsWidget")
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        //back online:
        //firebaseManager.changeOnlineStatus(isOnline: true)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        if #available(iOS 14.0, *) {
            
            WidgetCenter.shared.reloadTimelines(ofKind: "StepsWidget")
        }
    }
    
}


