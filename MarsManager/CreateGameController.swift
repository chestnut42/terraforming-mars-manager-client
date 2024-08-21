//
//  CreateGameController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 20/08/2024.
//

import UIKit
import os

protocol UserSearchControllerDelegate: AnyObject {
    func controllerDidChangedState(_ controller: UserSearchController)
}

class UserSearchController: NSObject, UITextFieldDelegate, APIHolder {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UserSearchController.self)
    )
    
    private var lastSuggestions: [String] = []
    private var currentRequestID: UUID = UUID()
    private var user: String?
    
    var api: MarsAPIService?
    
    weak var delegate: (any UserSearchControllerDelegate)?
    var currentUser: String? { get {
        if textField.isHidden {
            return nil
        }
        return user
    }}
    var isEnabled: Bool { get {
        return !textField.isHidden
    }}
    
    @IBOutlet var textField: UISearchTextField!
    
    @IBAction func archiveButtonPressed(sender: UIButton) {
        textField.isHidden = !textField.isHidden
        delegate?.controllerDidChangedState(self)
    }
    
    @IBAction func textDidChange(sender: UITextField) {
        let reqID = UUID()
        currentRequestID = reqID
        
        Task {
            guard let term = sender.text else {
                return
            }
            guard let api = self.api else {
                return
            }
            
            do {
                let resp = try await api.search(for: term)
                
                // Check if no new requests were made
                if currentRequestID != reqID {
                    return
                }
                
                let suggestions = resp.users.map { u in u.nickname }
                lastSuggestions = suggestions
                textField.searchSuggestions = suggestions.map({ n in
                    return UISearchSuggestionItem(localizedSuggestion: n)
                })
            } catch let error {
                logger.error("search call error: \(error)")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        for s in lastSuggestions {
            if s == textField.text {
                user = textField.text
                delegate?.controllerDidChangedState(self)
                return true
            }
        }
        
        // Suggestion not found
        user = nil
        delegate?.controllerDidChangedState(self)
        return true
    }
}

class CreateGameController: UIViewController, UserSearchControllerDelegate, APIHolder {
    var api: MarsAPIService?
    
    @IBOutlet var textControllers: [UserSearchController]!
    @IBOutlet var createButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tc in textControllers {
            tc.api = api
        }
        createButton.isEnabled = shouldEnableCreate()
    }
    
    @IBAction func createButtonPressed(sender: UIButton) {
        print("create: \(textControllers.map({ c in c.currentUser }))")
    }
    
    func controllerDidChangedState(_ controller: UserSearchController) {
        createButton.isEnabled = shouldEnableCreate()
    }
    
    private func shouldEnableCreate() -> Bool {
        var hasAtLeastOneUser = false
        for c in textControllers {
            if !c.isEnabled {
                continue
            }
            
            if c.currentUser == nil {
                // User is nil for enabled player
                return false
            }
            hasAtLeastOneUser = true
        }
        return hasAtLeastOneUser
    }
}
