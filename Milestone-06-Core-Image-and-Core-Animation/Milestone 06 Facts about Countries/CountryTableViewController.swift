//
//  CountryTableViewController.swift
//  Milestone 06 Facts about Countries
//
//  Created by Gerjan te Velde on 23/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class CountryTableViewController: UITableViewController {
    
    //MARK: - Objects and Properties
    var countries = [Country]()
    var regions = [String]()
    var regionsWithCountries = [String: [Country]]()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        DispatchQueue.global().async { [unowned self] in
            self.loadData()
            
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
                activityIndicator.stopAnimating()
            }
        }
    }

    //MARK: - Table View Datasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return regions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return regions[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let region = regions[section]
        return regionsWithCountries[region]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        
        let region = regions[indexPath.section]
        let country = regionsWithCountries[region]![indexPath.row]
        
        cell.textLabel?.text = country.name
        
        return cell
    }
    
    //MARK: - Methods
    func loadData() {
        if let url = URL(string: "https://countryapi.gear.host/v1/Country/getCountries"), let data = try? Data(contentsOf: url) {
            if let jsonData = try? JSONDecoder().decode(Root.self, from: data) {
                countries = jsonData.response
                groupCountriesBasedOnRegions()
            } else {
                print("CountryTableVC: Could not decode data.")
            }
        } else {
            print("CountryTableVC: Could not create URL or retrieve data.")
        }
    }
    
    func groupCountriesBasedOnRegions() {
        for country in countries {
            if regionsWithCountries[country.region] == nil {
                regionsWithCountries[country.region] = [country]
                regions.append(country.region)
            } else {
                regionsWithCountries[country.region]!.append(country)
            }
        }
        
        regions.sort(by: <)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "DetailSegue" else { return }
        
        let destination = segue.destination as! DetailCountryTableViewController
        let indexPath = tableView.indexPathForSelectedRow!
        
        let region = regions[indexPath.section]
        let country = regionsWithCountries[region]![indexPath.row]
        
        destination.country = country
    }
}

