//
//  ViewController.swift
//  Project 28 Secret Swift
//
//  Created by Gerjan te Velde on 14/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    //MARK: - Objects
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordInformationLabel: UILabel!
    @IBOutlet var secretTextView: UITextView!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nothing to see here"
        
        if KeychainWrapper.standard.string(forKey: "Password") == nil {
            passwordTextField.isHidden = true
            passwordInformationLabel.text = "Use Touch ID or Face ID to authenticate."
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }

    //MARK: - Actions
    @IBAction func authenticateButtonTouchUpInside(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?
        
        if !passwordTextField.isHidden && !passwordTextField.text!.isEmpty && passwordTextField.text! == KeychainWrapper.standard.string(forKey: "Password") {
            unlockSecretMessage()
        } else if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Identify yoourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self.unlockSecretMessage()
                    } else {
                        let alertController = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: true)
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Unable to authenticate", message: "Your password is wrong and device is not configured for biometric authentication.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }

    //MARK: - Methods
    func unlockSecretMessage() {
        secretTextView.isHidden = false
        title = "Secret stuff!"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Password", style: .plain, target: self, action: #selector(setPassword))
        
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secretTextView.text = text
        }
    }
    
    @objc func saveSecretMessage() {
        if !secretTextView.isHidden {
            KeychainWrapper.standard.set(secretTextView.text, forKey: "SecretMessage")
            secretTextView.resignFirstResponder()
            
            navigationItem.rightBarButtonItems = nil
            secretTextView.isHidden = true
            
            passwordTextField.text = ""
            title = "Nothing to see here"
        }
    }
    
    //MARK: - Helper Methods
    @objc func setPassword() {
        let alertController = UIAlertController(title: "Set Password", message: "If set before, the old password will be deleted.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter password here"
            textField.isSecureTextEntry = true
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Repeat password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "Save password", style: .default, handler: { [unowned self] (_) in
            if let textFields = alertController.textFields {
                guard !textFields[0].text!.isEmpty else {
                    print("Password cannot be empty String")
                    return
                }
                
                if textFields[0].text == textFields[1].text {
                    _ = KeychainWrapper.standard.set(textFields[0].text!, forKey: "Password")
                    print("New password stored")
                    
                    self.passwordTextField.isHidden = false
                    self.passwordInformationLabel.isHidden = false
                    self.passwordInformationLabel.text = "If password is wrong, Touch ID or Face ID will be tried."
                    
                    let alertController = UIAlertController(title: "Password saved!", message: "Next time you can login with your password.", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    self.present(alertController, animated: true)
                    
                } else {
                    print("Passwords do not match.")
                    let alertController = UIAlertController(title: "Passwords do not match", message: "Please try again.", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    self.present(alertController, animated: true)
                }
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "Delete password", style: .destructive, handler: { [unowned self] (_) in
            if let textFields = alertController.textFields {
                textFields[0].text = ""
                textFields[1].text = ""
            }
            
            self.passwordInformationLabel.text = "Use Touch ID or Face ID to authenticate."
            self.passwordTextField.isHidden = true
            
            KeychainWrapper.standard.removeObject(forKey: "Password")
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secretTextView.contentInset = UIEdgeInsets.zero
        } else {
            secretTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        secretTextView.scrollIndicatorInsets = secretTextView.contentInset
        
        let selectedRange = secretTextView.selectedRange
        secretTextView.scrollRangeToVisible(selectedRange)
    }
}


