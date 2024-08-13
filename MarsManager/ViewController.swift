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
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ViewController.self)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        activityView.isHidden = true
        
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
            guard let tokenData = appleIDCredential.identityToken else {
                logger.error("identity token is nil")
                return
            }
            guard let strToken = String(data: tokenData, encoding: .utf8) else {
                logger.error("can't create token string")
                return
            }
            
            logger.info("logged in: \(strToken)")
            
            Task {
                self.activityView.isHidden = false
                defer { self.activityView.isHidden = true }
                
                guard let baseURL = URL(string: "https://mars.blockthem.xyz") else {
                    logger.error("can't create base url")
                    return
                }
                
                let api = MarsAPIService(baseUrl: baseURL, token: strToken)
                do {
                    let response = try await api.login()
                    logger.info("logged in with \(response.user.nickname) (\(response.user.color.rawValue))")
                } catch let rd as APIError {
                    switch rd {
                    case .unknown(let message):
                        logger.error("unknown error: \(message)")
                    case .responseDecode(let data, _):
                        let dataStr = String(data: data, encoding: .utf8) ?? "<undecodable data>"
                        logger.error("decode error, data: \(dataStr)")
                    }
                } catch let error {
                    logger.info("error: \(error.localizedDescription)")
                }
            }
        
        default:
            logger.error("unexpected credential type")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        logger.error("authorization failed: \(error)")
    }
}

