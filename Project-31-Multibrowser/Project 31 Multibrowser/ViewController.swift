//
//  ViewController.swift
//  Project 31 Multibrowser
//
//  Created by Gerjan te Velde on 25/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    //MARK: - Outlets and Objects
    @IBOutlet var addressBar: UITextField!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var placeholderLabel: UILabel!
    
    weak var activeWebView: WKWebView?
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        addressBar.delegate = self
        addressBar.placeholder = "Enter URL here"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }

    //MARK: - Methods
    func setDefaultTitle() {
        title = "Multibrowser"
        addressBar.text = ""
        placeholderLabel.isHidden = false
        placeholderLabel.text = "Add new webview by tapping the + button in the top-right corner and type in a URL to get started."
    }

    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        placeholderLabel.isHidden = true
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.load(URLRequest(url: url))
        
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    @objc func deleteWebView() {
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.index(of: webView) {
                stackView.removeArrangedSubview(webView)
                
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    setDefaultTitle()
                } else {
                    var currentIndex = Int(index)
                    
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    func selectWebView(_ webView: WKWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUI(for: webView)
    }
    
    @objc func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
    
    func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        addressBar.text = "https://"
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
}

