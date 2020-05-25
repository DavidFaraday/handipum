//
//  ViewController.swift
//  Dating
//
//  Created by David Kababyan on 16/02/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    
    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backgroundView: UIImageView!
    
    
    //MARK: - VARs
    var notificationController: NotificationController!
    var activityIndicator: ActivityIndicator!


    
    //MARK: - View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark

        activityIndicator = ActivityIndicator(_view: self.view)
        notificationController = NotificationController(_view: self.view)
        setupBackgroundTouch()
    }

    //MARK: - IBACTIONS

    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
        if emailTextField.text != "" {
            FUser.resetPasswordFor(email: emailTextField.text!) { (error) in
                
                if error != nil {
                    self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
                } else {
                    self.notificationController.showNotification(text: "Please check your email!", isError: false)
                }
                
            }
        } else {
            notificationController.showNotification(text: "Please insert your email!", isError: true)
        }
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {

            FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, emailVerified) in
                
                if error != nil {
                    self.notificationController.showNotification(text: error!.localizedDescription, isError: true)
                    
                } else if emailVerified {

                    self.goToApp()
                } else {
                    self.notificationController.showNotification(text: "Please verify your email!", isError: true)
                }
            }
        } else {
            notificationController.showNotification(text: "All fields are required!", isError: true)
        }
        
    }
    
    
    @IBAction func appleButtonPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func googleButtonPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        
        
    }
    
    @objc func backgroundTap() {
        self.view.endEditing(false)
    }
    
    //MARK: - Setup
    private func setupBackgroundTouch() {
        backgroundView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        backgroundView.addGestureRecognizer(tapGesture)
    }

    //MARK: - Navigation
    
    private func goToApp() {
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }

}

