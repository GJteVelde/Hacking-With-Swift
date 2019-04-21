//
//  ShoppingListTableViewController.swift
//  Milestone 03 Shopping List
//
//  Created by Gerjan te Velde on 21/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ShoppingListTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var items = ["Apple", "Beer", "Vegetables"]
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareItems))
        
        navigationItem.rightBarButtonItems = [addBarButtonItem, shareBarButtonItem]
        navigationItem.leftBarButtonItem = editButtonItem
        
        tableView.allowsSelection = false
    }

    //MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemIdentifier", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: - Methods
    @objc func addNewItem() {
        let alert = UIAlertController(title: "Add new item", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter item here..."
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [unowned self] (_) in
            if let newItem = alert.textFields?[0].text {
                guard newItem != "" else { return }
                self.items.append(newItem)
                self.tableView.insertRows(at: [IndexPath(row: self.items.count - 1, section: 0)], with: .automatic)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc func shareItems() {
        let itemsString = items.joined(separator: "\n")
        
        let activityController = UIActivityViewController(activityItems: [itemsString], applicationActivities: nil)
        present(activityController, animated: true)
    }
}
