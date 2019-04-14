//
//  ViewController.swift
//  Project 32 SwiftSearcher
//
//  Created by Gerjan te Velde on 27/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController {

    //MARK: - Objects and Properties
    var projects = [Project]()
    var favorites = [Int]()
    var timesAdjustedForDynamicType = 0
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tap + to favorite projects!"
        
        projects.append(Project(title: "Project 1: Storm Viewer", subtitle: "Constants and variables, UITableView, UIImageView, FileManager, storyboards"))
        projects.append(Project(title: "Project 2: Guess the Flag", subtitle: "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"))
        projects.append(Project(title: "Project 3: Social Media", subtitle: "UIBarButtonItem, UIActivityViewController, the Social framework, URL"))
        projects.append(Project(title:"Project 4: Easy Browser", subtitle: "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"))
        projects.append(Project(title: "Project 5: Word Scramble", subtitle: "Closures, method return values, booleans, NSRange"))
        projects.append(Project(title: "Project 6: Auto Layout", subtitle: "Get to grips with Auto Layout using practical examples and code"))
        projects.append(Project(title: "Project 7: Whitehouse Petitions", subtitle: "JSON, Data, UITabBarController"))
        projects.append(Project(title: "Project 8: 7 Swifty Words", subtitle: "addTarget(), enumerated(), count, index(of:), property observers, range operators."))
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        
        let defaults = UserDefaults.standard
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
    }

    //MARK: - Table View Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        let project = projects[indexPath.row]
        cell.tekstLabel?.attributedText = makeAttributedString(title: project.title, subtitle: project.subtitle)
        
        if favorites.contains(indexPath.row) {
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if favorites.contains(indexPath.row) {
            return .delete
        } else {
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        } else {
            if let index = favorites.firstIndex(of: indexPath.row) {
                favorites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    //MARK: - Methods
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.kern: NSNumber(2)]
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        return titleString
    }
    
    func showTutorial(_ number: Int) {
        // +1 as tutorials start at 1, index starts at 0
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(number + 1)") {
            let configurations = SFSafariViewController.Configuration()
            configurations.entersReaderIfAvailable = true
            
            let safariViewController = SFSafariViewController(url: url, configuration: configurations)
            present(safariViewController, animated: true)
        }
    }
    
    func index(item: Int) {
        let project = projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project.title
        attributeSet.contentDescription = project.subtitle
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        item.expirationDate = Date.distantFuture
        CSSearchableIndex.default().indexSearchableItems([item]) { (error) in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func deindex(item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["(item)"]) { (error) in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
}

