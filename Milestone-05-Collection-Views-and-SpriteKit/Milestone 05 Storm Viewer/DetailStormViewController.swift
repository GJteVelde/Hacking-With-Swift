//
//  DetailStormViewController.swift
//  Milestone 05 Storm Viewer
//
//  Created by Gerjan te Velde on 23/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class DetailStormViewController: UIViewController {

    //MARK: - Objects and Properites
    var stormImage: String!

    @IBOutlet weak var stormImageView: UIImageView!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stormImageView.image = UIImage(named: stormImage)
        title = stormImage
    }
}
