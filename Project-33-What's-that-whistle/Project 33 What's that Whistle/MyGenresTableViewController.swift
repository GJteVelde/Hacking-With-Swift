//
//  MyGenresTableViewController.swift
//  Project 33 What's that Whistle
//
//  Created by Gerjan te Velde on 04/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var myGenres: [String]!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let savedGenres = defaults.object(forKey: "myGenres") as? [String] {
            myGenres = savedGenres
        } else {
            myGenres = [String]()
        }
        
        title = "Notify me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectGenreTableViewController.genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let genre = SelectGenreTableViewController.genres[indexPath.row]
        cell.textLabel?.text = genre
        
        if myGenres.contains(genre) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let selectedGenre = SelectGenreTableViewController.genres[indexPath.row]
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            } else {
                cell.accessoryType = .none
                
                if let index = myGenres.firstIndex(of: selectedGenre) {
                    myGenres.remove(at: index)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //MARK: - Methods
    @objc func saveTapped() {
        let defaults = UserDefaults.standard
        defaults.set(myGenres, forKey: "myGenres")
        
        let database = CKContainer.default().publicCloudDatabase
        
        database.fetchAllSubscriptions { [unowned self] (subscriptions, error) in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (string, error) in
                            if error != nil {
                                let alert = UIAlertController(title: "Error", message: "We couldn't delete this subscription: \(error!.localizedDescription)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(alert, animated: true)
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                    for genre in self.myGenres {
                        let predicate = NSPredicate(format: "genre = %@", genre)
                        let subscription = CKQuerySubscription(recordType: "Whistles", predicate: predicate, options: .firesOnRecordCreation)
                        
                        let notification = CKSubscription.NotificationInfo()
                        notification.alertBody = "There is a new whistle in the \(genre) genre."
                        notification.soundName = "default"
                        
                        subscription.notificationInfo = notification
                        
                        database.save(subscription, completionHandler: { (result, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        })
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "We couldn't delete your subscriptions: \(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                print(error!.localizedDescription)
            }
        }
    }
}
