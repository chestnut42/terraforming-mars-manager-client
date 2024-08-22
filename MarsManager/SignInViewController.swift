//
//  ViewController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 12/08/2024.
//

import AuthenticationServices
import os
import UIKit

protocol APIHolder {
    var api: MarsAPIService? { get set }
}

extension Notification.Name {
    static var apiCreated: Notification.Name {
        return Notification.Name("mars.manager.api.created")
    }
}

class SignInViewController:
    UIViewController,
    ASAuthorizationControllerPresentationContextProviding,
    ASAuthorizationControllerDelegate
{
    @IBOutlet var signInBaseView: UIView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    var api: MarsAPIService?
    
    // View Controller stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        activityView.isHidden = true
        
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        var f = self.signInBaseView.frame
        f.origin = .zero
        appleButton.frame = f
        self.signInBaseView.addSubview(appleButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var holder = segue.destination as? APIHolder {
            holder.api = self.api
        }
    }

    
    // Handlers
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

    
    // Sign In With Apple
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        self.processAsyc {
            let token = try self.parseIdentityToken(authorization: authorization)
            guard let baseURL = URL(string: "https://mars.blockthem.xyz") else {
                throw APIError.undefined(message: "can't create base url")
            }
            
            self.activityView.isHidden = false
            defer { self.activityView.isHidden = true }
            
            let api = MarsAPIService(baseUrl: baseURL, token: token)
            let user = try await api.login()
            self.api = api
            
            NotificationCenter.default.post(name: .apiCreated, object: nil, userInfo: ["api": api])
            
            // Register for notifications
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert, .badge, .sound
            ])
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
            self.performSegue(withIdentifier: "StartToTab", sender: nil)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        self.processAsyc {
            throw APIError.undefined(message: "authorization failed: \(error.localizedDescription)")
        }
    }
    
    
    // Methods
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

