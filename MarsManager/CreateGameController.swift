//
//  CreateGameController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 20/08/2024.
//

import UIKit
import os

@objc protocol UserSearchControllerDelegate: AnyObject {
    func controllerDidChangedState(_ controller: UserSearchController)
}

class UserSearchController: NSObject, UISearchTextFieldDelegate, APIHolder {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: UserSearchController.self)
    )
    
    private var lastSuggestions: [String] = []
    private var currentRequestID: UUID = UUID()
    private var user: String?
    
    var api: MarsAPIService?
    
    var currentUser: String? { get {
        if textField.isHidden {
            return nil
        }
        return user
    }}
    var isEnabled: Bool { get {
        return !textField.isHidden
    }}
    
    @IBOutlet weak var delegate: (any UserSearchControllerDelegate)?
    @IBOutlet var textField: UISearchTextField!
    
    @IBAction func archiveButtonPressed(sender: UIButton) {
        textField.isHidden = !textField.isHidden
        delegate?.controllerDidChangedState(self)
    }
    
    @IBAction func textDidChange(sender: UITextField) {
        Task {
            await reloadSuggestions()
        }
    }
    
    func reloadSuggestions() async {
        let reqID = UUID()
        currentRequestID = reqID
        
        guard let term = textField.text else {
            return
        }
        guard let api = self.api else {
            return
        }
        
        do {
            let users = try await api.search(for: term)
            
            // If no new requests were made - drop this response
            if currentRequestID != reqID {
                return
            }
            // If editing was finished - drop this response
            if !textField.isFirstResponder {
                return
            }
            
            let suggestions = users.map { u in u.nickname }
            lastSuggestions = suggestions
            textField.searchSuggestions = suggestions.map({ n in
                return UISearchSuggestionItem(localizedSuggestion: n)
            })
        } catch let error {
            logger.error("search call error: \(error)")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Task {
            await reloadSuggestions()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.textField.searchSuggestions = nil
        
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
    
    func searchTextField(_ searchTextField: UISearchTextField, didSelect suggestion: any UISearchSuggestion) {
        textField.resignFirstResponder()
        textField.text = suggestion.localizedSuggestion
        user = suggestion.localizedSuggestion
        delegate?.controllerDidChangedState(self)
    }
}

protocol CreateGameControllerDelegate: AnyObject {
    func gameControllerDidCreateGame(_ controller: CreateGameController)
}

class CreateGameController: UIViewController, UserSearchControllerDelegate, APIHolder {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CreateGameController.self)
    )
    
    var api: MarsAPIService?
    weak var delegate: CreateGameControllerDelegate?
    
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
        guard let api = self.api else {
            return
        }
        
        let players = textControllers.compactMap({ u in u.currentUser })
        Task {
            do {
                _ = try await api.createGame(players: players)
            } catch let error {
                logger.error("failed to create a game: \(error.localizedDescription)")
            }
            self.presentingViewController?.dismiss(animated: true)
        }
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
