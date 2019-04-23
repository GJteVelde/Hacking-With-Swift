//
//  StormCollectionViewController.swift
//  Milestone 05 Storm Viewer
//
//  Created by Gerjan te Velde on 23/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class StormCollectionViewController: UICollectionViewController {
    
    //MARK: - Objects and Properties
    var stormImages = [String]()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImages()
    }

    //MARK: - Collection View Datasource Methods
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stormImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StormCell", for: indexPath) as! StormCollectionViewCell
        
        let image = stormImages[indexPath.row]
        cell.stormImageView.image = UIImage(named: image)
        cell.stormImageTitleLabel.text = image
        
        return cell
    }
    
    //MARK: - Collection View Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailStormSegue", sender: self)
    }
    
    //MARK: - Methods
    func loadImages() {
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        
        if let content = try? fileManager.contentsOfDirectory(atPath: path) {
            for item in content {
                if item.hasPrefix("nssl") {
                    stormImages.append(item)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "DetailStormSegue" else { return }
        
        guard let destination = segue.destination as? DetailStormViewController else { return }
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        destination.stormImage = stormImages[indexPath.row]
    }
}
