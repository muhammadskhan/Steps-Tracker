//
//  ViewController.swift
//  Steps Calculator
//
//  Created by Haseeb Javed on 24/08/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import UIKit
import Firebase
import AuthenticationServices
import SVProgressHUD

class AuthenticationViewController: UIViewController {
    
    var viewModel: AuthenticationViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = AuthenticationViewModel(viewDelegate: self)
        self.setupSignInButton()
        dataManager.isReviewDone = true
    }
    
    func setupSignInButton() {
        let btnApple = ASAuthorizationAppleIDButton()
        btnApple.frame = CGRect(x: 20, y: 500, width: 300, height: 50)
        btnApple.cornerRadius = 20; 
        btnApple.addTarget(self, action: #selector(self.handleSignInWithAppleTapped), for: .touchUpInside)
        btnApple.center = view.center
        view.addSubview(btnApple)
        //btnApple.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    @objc func handleSignInWithAppleTapped() {
        
        SVProgressHUD.show(withStatus:"Signing In")
        self.viewModel?.appleSignInTapped()
    }
}

extension AuthenticationViewController: SignInResultDelegate {
    
    func signIn(success: Bool, error: String?) {
        
        if success {
            
            fsManager.getUserInfo(withId: dataManager.userId) { (user, error) in
                
                if user != nil {
                    
                    dataManager.user = user
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    navigationManager.showHomeScreen()
                }
                guard let userId = dataManager.user?.userId, userId.count > 0 else {
                    return
                }
                purchasesManager.updateUserId(userId: userId)
            }
        } else {
            
            DispatchQueue.main.async {
                
                SVProgressHUD.dismiss()
                Alert.showAlert(on: self, with: Constants.appName, message: error ?? "Something went wrong")
            }
        }
    }
}

