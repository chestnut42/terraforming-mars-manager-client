//
//  TaskExtension.swift
//  MarsManager
//
//  Created by Andrei Makarych on 22/08/2024.
//

import Foundation
import UIKit
import os

protocol AsyncProcessor {
    func processAsyc(_ closure: @escaping () async throws -> Void)
}

extension UIViewController: AsyncProcessor {
    public func processAsyc(_ closure: @escaping () async throws -> Void) {
        Task {
            do {
                try await closure()
            } catch let error {
                let alertMessagePopUpBox = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default)
                
                alertMessagePopUpBox.addAction(okButton)
                self.present(alertMessagePopUpBox, animated: true)
            }
        }
    }
}
