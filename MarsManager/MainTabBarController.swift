//
//  MainTabBarController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 18/08/2024.
//

import UIKit

class MainTabBarController: UITabBarController, APIHolder {
    var api: MarsAPIService?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for ctrl in self.viewControllers ?? [] {
            if var holder = ctrl as? APIHolder {
                holder.api = self.api
            }
        }
    }
}
