//
//  SubmitViewController.swift
//  Project 33 What's that Whistle
//
//  Created by Gerjan te Velde on 28/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CloudKit

class SubmitViewController: UIViewController {

    //MARK: - Objects and Properties
    var genre: String!
    var comments: String!
    
    var stackView: UIStackView!
    var statusLabel: UILabel!
    var spinner: UIActivityIndicatorView!
    
    //MARK: - Life Cycle
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "Submitting..."
        statusLabel.textColor = UIColor.white
        statusLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(spinner)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "You're all set!"
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        doSubmission()
    }
    
    //MARK: - Methods
    func doSubmission() {
        let whistleRecord = CKRecord(recordType: "Whistles")
        whistleRecord["genre"] = genre as CKRecordValue
        whistleRecord["comments"] = comments as CKRecordValue
        
        let audioURL = RecordWhistleViewController.getWhistleURL()
        let whistleAsset = CKAsset(fileURL: audioURL)
        whistleRecord["audio"] = whistleAsset
        
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.statusLabel.text = "Error: \(error.localizedDescription)"
                    self.spinner.stopAnimating()
                } else {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    self.statusLabel.text = "Done!"
                    self.spinner.stopAnimating()
                    
                    WhistlesTableViewController.isDirty = true
                }
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
            }
        }
    }
    
    @objc func doneTapped() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
}
