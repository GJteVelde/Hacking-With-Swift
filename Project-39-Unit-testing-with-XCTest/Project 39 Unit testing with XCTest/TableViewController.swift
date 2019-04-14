//
//  TableViewController.swift
//  Project 39 Unit testing with XCTest
//
//  Created by Gerjan te Velde on 10/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var playData = PlayData()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
    }

    //MARK: - Table View Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playData.filteredWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let word = playData.filteredWords[indexPath.row]
        cell.textLabel!.text = word
        cell.detailTextLabel!.text = "\(playData.wordCounts.count(for: word))"

        return cell
    }
    
    //MARK: - Methods
    @objc func searchTapped() {
        let alert = UIAlertController(title: "Filter...", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Filter", style: .default, handler: { [unowned self] (_) in
            let userInput = alert.textFields?[0].text ?? ""
            
            if userInput == "" {
                self.playData.applyUserFilter("swift")
            } else {
                self.playData.applyUserFilter(userInput)
            }
            
            self.tableView.reloadData()
        }))
        
        //alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] (_) in
            self.playData.applyUserFilter("swift")
            self.tableView.reloadData()
        }))
        
        present(alert, animated: true)
    }
}

