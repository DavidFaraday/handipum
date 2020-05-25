//
//  RegisterViewController.swift
//  Dating
//
//  Created by David Kababyan on 16/02/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var genderSegmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    //MARK: - Vars
    var notificationController: NotificationController!
    var activityIndicator: ActivityIndicator!

    var isMale = true
    var datePicker = UIDatePicker()
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    //MARK: - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark

        activityIndicator = ActivityIndicator(_view: self.view)
        notificationController = NotificationController(_view: self.view)
        
        setupBackgroundTap()
        setupDatePicker()
    }
    

    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        if isTextDataImputed() {
            registerUser()
        } else {
            notificationController.showNotification(text: "All fields are required!", isError: true)
        }
        
    }
    @IBAction func genderSegmentValueChanged(_ sender: UISegmentedControl) {
        
        isMale = sender.selectedSegmentIndex == 0 ? true : false
    }
    
    @IBAction func appleButtonPressed(_ sender: Any) {

    }
    
    
    @IBAction func googleButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func backgroundTap() {
        dismissKeyboard()
    }
    
    
    
    //MARK: - Register
    
    private func registerUser() {
        
        self.activityIndicator.showLoadingIndicator()

        FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, userName: usernameTextField.text!, city: cityTextField.text!, isMale: isMale, dateOfBirth: datePicker.date) { (error) in
            
            self.activityIndicator.hideLoadingIndicator()
            
            if error == nil {
                
                self.notificationController.showNotification(text: "Verification email sent!", isError: false)

            } else {
                self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
            }            
        }
    }

    
    //MARK: - Helpers
    
    private func isTextDataImputed() -> Bool {
        
        return usernameTextField.text != "" && emailTextField.text != "" && cityTextField.text != "" && dateOfBirthTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != ""
    }
    
    @objc func handleDatePicker() {
        dateOfBirthTextField.text = datePicker.date.longDate()
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @objc func doneClicked() {
        dismissKeyboard()
    }


    private func setupDatePicker() {
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        dateOfBirthTextField.inputView = datePicker


        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor().primary()
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClicked))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        dateOfBirthTextField.inputAccessoryView = toolBar

    }
    
    private func setupBackgroundTap() {
        tapGestureRecognizer.addTarget(self, action: #selector(backgroundTap))
        
        backgroundImageView.addGestureRecognizer(tapGestureRecognizer)
        backgroundImageView.isUserInteractionEnabled = true
    }
}



