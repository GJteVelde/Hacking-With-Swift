//
//  SelectGenreTableViewController.swift
//  Project 33 What's that Whistle
//
//  Created by Gerjan te Velde on 28/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class SelectGenreTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    static var genres = ["Unknown", "Blues", "Classical", "Electronic", "Jazz", "Metal", "Pop", "Reggae", "RnB", "Rock", "Soul"]
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select genre"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Genre", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    //MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectGenreTableViewController.genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = SelectGenreTableViewController.genres[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //MARK: - Table Viewe Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let genre = cell.textLabel?.text ?? SelectGenreTableViewController.genres[0]
            let addCommentsViewController = AddCommentsViewController()
            addCommentsViewController.genre = genre
            navigationController?.pushViewController(addCommentsViewController, animated: true)
        }
    }
}
