//
//  AuthenticationViewModel.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 09/09/2020.
//  Copyright © 2020 HxB. All rights reserved.
//

import Foundation
import Firebase
import AuthenticationServices
import CryptoKit
import FirebaseUI

protocol AuthenticationViewModelDelegate {
    func appleSignInTapped()
}

protocol SignInResultDelegate {
    func signIn(success: Bool, error: String?)
}

class AuthenticationViewModel: NSObject {
    
    var signInResultDelegate: SignInResultDelegate?
    fileprivate var currentNonce: String?
    
    init(viewDelegate: SignInResultDelegate) {
        signInResultDelegate = viewDelegate
       
    }
    
    func performSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
}

extension AuthenticationViewModel: AuthenticationViewModelDelegate {
    
    func appleSignInTapped() {
        
        self.performSignIn()
    }
}

extension AuthenticationViewModel : FUIAuthDelegate, ASAuthorizationControllerDelegate {
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                signInResultDelegate?.signIn(success: false, error: "Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                
                signInResultDelegate?.signIn(success: false, error: "Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            var name = ""
            if let value = appleIDCredential.fullName {
                
                name =  String(format: "%@ %@", (value.givenName ?? ""), (value.familyName ?? ""))
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            //Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    
                    self.signInResultDelegate?.signIn(success: false, error: error?.localizedDescription)
                    return
                }
                dataManager.userId = Auth.auth().currentUser?.uid ?? ""
                if name != "" && name != " " {
                    
                    fsManager.createUser(user: User(userId: dataManager.userId, userName: name, userEmail: appleIDCredential.email ?? "")) { (success, error) in
                        
                        if error != nil {
                            
                            self.signInResultDelegate?.signIn(success: false, error: error?.localizedDescription)
                        } else {
                            
                            self.signInResultDelegate?.signIn(success: true, error: nil)
                        }
                    }
                } else {
                    self.signInResultDelegate?.signIn(success: true, error: nil)
                }
            }
        }
    }

      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        self.signInResultDelegate?.signIn(success: false, error: "Sign in with Apple errored: \(error)")
      }
}
