//
//  ViewController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 12/08/2024.
//

import AuthenticationServices
import os
import UIKit

class ViewController: 
    UIViewController,
    ASAuthorizationControllerPresentationContextProviding,
    ASAuthorizationControllerDelegate
{
    @IBOutlet var signInBaseView: UIView!
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ViewController.self)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.signInBaseView.addSubview(appleButton)
    }

    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            if let tokenData = appleIDCredential.identityToken,
                let strToken = String(data: tokenData, encoding: .utf8){
                logger.info("logged in: \(strToken)")
            } else {
                logger.error("empty identity token")
            }
        
        default:
            logger.error("unexpected credential type")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        logger.error("authorization failed: \(error)")
    }
}

