//
//  DetailCountryTableViewController.swift
//  Milestone 06 Facts about Countries
//
//  Created by Gerjan te Velde on 23/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class DetailCountryTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var country: Country!
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = country.name
        regionLabel.text = country.region
        currencyNameLabel.text = country.currencyName
        
        DispatchQueue.global().async { [unowned self] in
            if let url = URL(string: self.country.flagPng), let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async { [unowned self] in
                        self.flagImageView.alpha = 0
                        self.flagImageView.image = image
                        
                        UIView.animate(withDuration: 1, animations: {
                            self.flagImageView.alpha = 1
                        })
                    }
                }
            }
        }
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 0, section: 0) {
            return (view.frame.width / 2)
        }
        
        if country.region == "" && indexPath == IndexPath(row: 0, section: 1) {
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if country.region == "" && section == 1 {
            regionLabel.isHidden = true
            return 0
        }
        
        return UITableView.automaticDimension
    }
}
