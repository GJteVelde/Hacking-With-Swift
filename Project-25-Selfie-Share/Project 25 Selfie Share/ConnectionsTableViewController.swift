//
//  ConnectionsTableViewController.swift
//  Project 25 Selfie Share
//
//  Created by Gerjan te Velde on 10/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ConnectionsTableViewController: UITableViewController {

    var connectedDevices = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        cell.textLabel?.text = connectedDevices[indexPath.row]
        return cell
    }
}
