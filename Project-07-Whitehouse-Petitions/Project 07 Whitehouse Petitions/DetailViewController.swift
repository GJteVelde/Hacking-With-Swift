//
//  DetailViewController.swift
//  Project 07 Whitehouse Petitions
//
//  Created by Gerjan te Velde on 31/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else { return }
        
        let html = """
        <html>
            <head>
            	<meta name="viewpor" content="width=device-width, initial-scale=1">
                <style> body { font-size: 300%; } </style>
            </head>
            <body>
                \(detailItem.body)
            </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}
