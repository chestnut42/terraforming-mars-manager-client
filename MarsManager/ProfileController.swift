//
//  ProfileController.swift
//  MarsManager
//
//  Created by Andrei Makarych on 22/08/2024.
//

import UIKit

class ProfileController: UIViewController, APIHolder, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var api: MarsAPIService?
    
    @IBOutlet var nicknameField: UITextField!
    @IBOutlet var colorPicker: UIPickerView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    private func reloadData() {
        self.processAsyc {
            self.activityView.isHidden = false
            defer { self.activityView.isHidden = true }
            
            guard let api = self.api else {
                throw APIError.undefined(message: "no api object is set")
            }
            
            let user = try await api.getMe()
            self.nicknameField.text = user.nickname
            self.colorPicker.selectRow(Color.allCases.firstIndex(of: user.color) ?? 0, inComponent: 0, animated: true)
        }
    }
    
    @objc func appDidBecomeActive(_ notification: Notification) {
        reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadData()
    }
    
    @IBAction func saveButtonPressed(sender: Any) {
        self.nicknameField.resignFirstResponder()
        self.processAsyc {
            self.activityView.isHidden = false
            defer { self.activityView.isHidden = true }
            
            guard let api = self.api else {
                throw APIError.undefined(message: "no api object is set")
            }
            
            let user = try await api.updateMe(nickname: self.nicknameField.text ?? "",
                                              color: Color.allCases[self.colorPicker.selectedRow(inComponent: 0)])
            self.nicknameField.text = user.nickname
            self.colorPicker.selectRow(Color.allCases.firstIndex(of: user.color) ?? 0, inComponent: 0, animated: true)
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Color.allCases.count
    }
    
    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Color.allCases[row].rawValue
    }
}
