//
//  AppDelegate.swift
//  MarsManager
//
//  Created by Andrei Makarych on 12/08/2024.
//

import UIKit
import os

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AppDelegate.self)
    )
    
    var api: MarsAPIService?

    deinit {
        NotificationCenter.default.removeObserver(self, name: .apiCreated, object: nil)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(apiCreated(_:)), name: .apiCreated, object: nil)
        return true
    }
    
    @objc func apiCreated(_ notification: Notification) {
        guard let api = notification.userInfo?["api"] as? MarsAPIService else {
            logger.error("\(Notification.Name.apiCreated.rawValue) notification does not have api service")
            return
        }
        self.api = api
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let api = self.api else {
            logger.error("device token received: no API object")
            return
        }
        
        Task {
            do {
                _ = try await api.update(deviceToken: deviceToken)
                logger.info("device token updated")
            } catch let error {
                logger.error("failed to update device token: \(error.localizedDescription)")
            }
        }
    }
}

