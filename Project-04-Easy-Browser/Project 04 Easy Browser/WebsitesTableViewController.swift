//
//  WebsitesTableViewController.swift
//  Project 04 Easy Browser
//
//  Created by Gerjan te Velde on 27/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class WebsitesTableViewController: UITableViewController {

    var websites: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let websitesPath = Bundle.main.path(forResource: "Websites", ofType: "txt") {
            if let websitesContent = try? String(contentsOfFile: websitesPath) {
                websites = websitesContent.components(separatedBy: "\n")
                websites.removeAll { $0 == "" }
            } else {
                loadDefaultWebsite()
            }
        } else {
            loadDefaultWebsite()
        }
        
        title = "Websites"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewWebsite))
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebsiteCell", for: indexPath)
        
        cell.textLabel?.text = websites[indexPath.row]

        return cell
    }
    
    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete website: \(websites[indexPath.row])")
            websites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WebsiteSelected" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let destination = segue.destination as! ViewController
                destination.websites = websites
                destination.selectedWebsite = websites[indexPath.row]
            }
        }
    }
    
    //MARK: - Methods
    func loadDefaultWebsite() {
        websites = ["apple.com"]
    }
    
    @objc func addNewWebsite() {
        let alertController = UIAlertController(title: "Add new website", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "example.com"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned self, alertController] (_) in
            if let textField = alertController.textFields?.first, let website = textField.text {
                self.websites.insert(website, at: 1)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                print("Add new website: \(website)")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
