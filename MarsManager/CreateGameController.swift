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
    private var lastSuggestions: [String] = []
    private var currentRequestID: UUID = UUID()
    private var user: String?
    
    var api: MarsAPIService?
    weak var processor: (any AsyncProcessor & AnyObject)?
    
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
        guard let term = textField.text else {
            return
        }
        
        self.processor!.processAsyc {
            let reqID = UUID()
            self.currentRequestID = reqID
            
            guard let api = self.api else {
                throw APIError.undefined(message: "no api object is set")
            }
            
            let users = try await api.search(for: term)
            // If no new requests were made - drop this response
            if self.currentRequestID != reqID {
                return
            }
            // If editing was finished - drop this response
            if !self.textField.isFirstResponder {
                return
            }
            
            let suggestions = users.map { u in u.nickname }
            self.lastSuggestions = suggestions
            self.textField.searchSuggestions = suggestions.map({ n in
                return UISearchSuggestionItem(localizedSuggestion: n)
            })
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

class CreateGameController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UserSearchControllerDelegate, APIHolder {
    var api: MarsAPIService?
    weak var delegate: CreateGameControllerDelegate?
    
    @IBOutlet var textControllers: [UserSearchController]!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var boardSelector: UIPickerView!
    @IBOutlet var corporateEraToggle: UISwitch!
    @IBOutlet var preludeToggle: UISwitch!
    @IBOutlet var venusNextToggle: UISwitch!
    @IBOutlet var solarPhaseToggle: UISwitch!
    @IBOutlet var coloniesToggle: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tc in textControllers {
            tc.api = api
            tc.processor = self
        }
        createButton.isEnabled = shouldEnableCreate()
    }
    
    @IBAction func createButtonPressed(sender: UIButton) {
        self.processAsyc {
            guard let api = self.api else {
                throw APIError.undefined(message: "no api object is set")
            }
            
            _ = try await api.createGame(request: CreateGameRequest(
                players: self.textControllers.compactMap({ u in u.currentUser }),
                board: Board.allCases[self.boardSelector.selectedRow(inComponent: 0)],
                corporateEra: self.corporateEraToggle.isOn,
                prelude: self.preludeToggle.isOn,
                venusNext: self.venusNextToggle.isOn,
                solarPhase: self.venusNextToggle.isOn,
                colonies: self.coloniesToggle.isOn
            ))
            
            self.delegate?.gameControllerDidCreateGame(self)
        }
    }
    
    func controllerDidChangedState(_ controller: UserSearchController) {
        createButton.isEnabled = shouldEnableCreate()
    }
    
    private func shouldEnableCreate() -> Bool {
        var userList: [String] = []
        for c in textControllers {
            if !c.isEnabled {
                continue
            }
            
            guard let cu = c.currentUser else {
                // User is nil for enabled player
                return false
            }
            userList.append(cu)
        }
        let userSet: Set = Set(userList)
        return userList.count >= 1 && userList.count == userSet.count
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Board.allCases.count
    }
    
    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Board.allCases[row].rawValue
    }
}
