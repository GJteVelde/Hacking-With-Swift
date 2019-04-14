//
//  TableViewController.swift
//  Project 38 GitHub Commits
//
//  Created by Gerjan te Velde on 05/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    //MARK: - Objects and Properties
    var container: NSPersistentContainer!
    var commitPredicate: NSPredicate?
    var fetchedResultsController: NSFetchedResultsController<Commit>!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = NSPersistentContainer(name: "Project38")
        
        container.loadPersistentStores { (storeDescription, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(fetchCommits))
        
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        loadSavedData()
    }

    //MARK: - Table View Data Source Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        let commit = fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name
    }
    
    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailViewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            detailViewController.detailItem = fetchedResultsController.object(at: indexPath)
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
            saveContext()
        }
    }
    
    //MARK: - Methods
    @objc func fetchCommits() {
        let newestCommitDate = getNewestCommitDate()
        
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {
            let jsonCommits = JSON(parseJSON: data)
            let jsonCommitArray = jsonCommits.arrayValue
            print("Received \(jsonCommitArray.count) new commits.")
            
            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext)
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                
                self.saveContext()
                self.loadSavedData()
            }
        }
    }
    
    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()
        
        let defaults = UserDefaults.standard
        
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1
        
        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                let newCommitDate = commits[0].date.addingTimeInterval(1)
                
                if let savedCommitDate = defaults.object(forKey: "savedCommitDate") as? Date {
                    if newCommitDate >= savedCommitDate {
                        print("New savedCommitDate is set: \(formatter.string(from: newCommitDate))")
                        defaults.set(newCommitDate, forKey: "savedCommitDate")
                        return formatter.string(from: newCommitDate)
                    } else {
                        print("savedCommitDate is more recent and has been returned: \(formatter.string(from: savedCommitDate))")
                        return formatter.string(from: savedCommitDate)
                    }
                }
            } else {
                if let savedCommitDate = defaults.object(forKey: "savedCommitDate") as? Date {
                    print("No date could be fetched, savedCommitDate has been returned.")
                    return formatter.string(from: savedCommitDate)
                }
            }
        } else {
            if let savedCommitDate = defaults.object(forKey: "savedCommitDate") as? Date {
                print("No date could be fetched, savedCommitDate has been returned.")
                return formatter.string(from: savedCommitDate)
            }
        }
        
        print("Date could neither be fetched nor loaded from UserDefaults.")
        return formatter.string(from: Date(timeIntervalSince1970: 0))
    }
    
    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
        var commitAuthor: Author!
        
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        commit.author = commitAuthor
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
            
        fetchedResultsController.fetchRequest.predicate = commitPredicate
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    @objc func changeFilter() {
        let filterAlert = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        
        filterAlert.addAction(UIAlertAction(title: "Show only fixes", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")
            self.loadSavedData()
        }))
        
        filterAlert.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")
            self.loadSavedData()
        }))
        
        filterAlert.addAction(UIAlertAction(title: "Show only recent", style: .default, handler: { [unowned self] (_) in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)
            self.loadSavedData()
        }))
        
        filterAlert.addAction(UIAlertAction(title: "Show only Durian commits", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData()
        }))
        
        filterAlert.addAction(UIAlertAction(title: "Show all commits", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = nil
            self.loadSavedData()
        }))
        
        filterAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(filterAlert, animated: true)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
}

