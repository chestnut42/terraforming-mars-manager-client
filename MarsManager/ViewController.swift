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
    @IBOutlet var statusText: UITextView!
    
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
        do {
            let token = try self.parseIdentityToken(authorization: authorization)
            logger.info("logged in: \(token)")
            
            guard let baseURL = URL(string: "https://mars.blockthem.xyz") else {
                throw APIError.undefined(message: "can't create base url")
            }
            
            Task {
                self.activityView.isHidden = false
                defer { self.activityView.isHidden = true }
                
                let api = MarsAPIService(baseUrl: baseURL, token: token)
                do {
                    let response = try await api.login()
                    logger.info("logged in with \(response.user.nickname) <\(response.user.id)> (\(response.user.color.rawValue))")
                } catch let error {
                    self.statusText.text = error.localizedDescription
                }
            }
        } catch let error {
            self.statusText.text = error.localizedDescription
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        logger.error("authorization failed: \(error)")
    }
    
    func parseIdentityToken(authorization: ASAuthorization) throws  -> String {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard let tokenData = appleIDCredential.identityToken else {
                throw APIError.undefined(message: "authorization does not have identity token")
            }
            guard let strToken = String(data: tokenData, encoding: .utf8) else {
                throw APIError.undefined(message: "can't convert identity token to string")
            }
            
            return strToken
        default:
            throw APIError.undefined(message: "unexpected credential type")
        }
    }
}

