//
//  DetailViewController.swift
//  Milestone 02 Flags
//
//  Created by Gerjan te Velde on 20/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //MARK: - Objects and Properties
    var flag: String!
    var country: String!
    
    @IBOutlet weak var flagImageView: UIImageView!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        title = country
        flagImageView.image = UIImage(named: flag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareFlag))
    }
    
    //MARK: - Methods
    @objc func shareFlag() {
        let activityViewController = UIActivityViewController(activityItems: [country!, UIImage(named: flag)!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityViewController, animated: true)
    }
}
