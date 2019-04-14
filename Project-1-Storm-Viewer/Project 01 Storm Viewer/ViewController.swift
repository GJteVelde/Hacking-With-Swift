//
//  ViewController.swift
//  Project 01 Storm Viewer
//
//  Created by Gerjan te Velde on 17/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    //MARK: - Variables
    var pictures: [String] = []
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Storm Viewer"
        
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fileManager.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
    }

    //MARK: - Table View Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath) as! StormViewerTableViewCell
        
        let image = pictures[indexPath.row]
        cell.title.text = image
        cell.stormImageView.image = UIImage(named: image)
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Try loading the detailViewController and typecasting it to be DetailViewController
        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            //If success, set its selectedImage property
            detailViewController.selectedImage = pictures[indexPath.row]
            //Push the detailViewController onto the navigation controller
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}

