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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityView.isHidden = true
    }
    
    @IBAction func saveButtonPressed(sender: Any) {
        
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
