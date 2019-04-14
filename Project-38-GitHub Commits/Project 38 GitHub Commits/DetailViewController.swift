//
//  DetailViewController.swift
//  Project 38 GitHub Commits
//
//  Created by Gerjan te Velde on 05/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {

    //MARK: - Objects and Properties
    var webView: WKWebView!
    var spinner: UIActivityIndicatorView!
    
    var detailItem: Commit?
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let detail = self.detailItem {
            if let url = URL(string: detail.url) {
                webView = WKWebView()
                webView.navigationDelegate = self
                webView.allowsBackForwardNavigationGestures = true
                view = webView
                
                showSpinner()
                
                title = detail.author.name
                
                let urlRequest = URLRequest(url: url)
                webView.load(urlRequest)
            }
            
            //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.commits.count)", style: .plain, target: self, action: #selector(showAuthorCommits))
        }
    }
    
    //MARK: - Method
    @objc func showAuthorCommits() {
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        showSpinner()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
        navigationItem.rightBarButtonItem = nil
    }
    
    func showSpinner() {
        spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }
}
