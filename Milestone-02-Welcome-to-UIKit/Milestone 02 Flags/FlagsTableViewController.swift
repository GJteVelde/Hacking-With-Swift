//
//  FlagsTableViewController.swift
//  Milestone 02 Flags
//
//  Created by Gerjan te Velde on 20/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class FlagsTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var flags = [String: String]()
    var countries = [String]()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFlags()
    }

    //MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell", for: indexPath)
        
        let country = countries[indexPath.row]
        cell.textLabel?.text = country
        cell.imageView?.image = UIImage(named: flags[country]!)
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
    //MARK: - Methods
    func loadFlags() {
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        
        if let items = try? fileManager.contentsOfDirectory(atPath: path) {
            for item in items {
                if item.hasSuffix(".png") {
                    var country = item
                    country.removeLast(4)
                    
                    if country.count <= 2 {
                        country = country.uppercased()
                    } else {
                        country = country.capitalized
                    }
                    
                    countries.append(country)
                    flags[country] = item
                }
            }
        }
        
        countries.sort(by: <)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Detail" else { return }
        
        let country = countries[tableView.indexPathForSelectedRow!.row]
        
        if let detailViewController = segue.destination as? DetailViewController {
            detailViewController.country = country
            detailViewController.flag = flags[country]!
        }
    }
}
