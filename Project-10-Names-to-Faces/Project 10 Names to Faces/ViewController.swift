//
//  ViewController.swift
//  Project 10 Names to Faces
//
//  Created by Gerjan te Velde on 03/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Objects
    var people = [Person]()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("Failed to load people.")
            }
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    //MARK: - Collection View Datasource Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCollectionViewCell
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = url.appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    //MARK: - Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = url.appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unkown", image: imageName)
        people.append(person)
        collectionView?.reloadData()
        save()
        
        dismiss(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let alertController = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [unowned self] (_) in
            let newName = alertController.textFields![0]
            person.name = newName.text!
            
            self.collectionView?.reloadData()
            self.save()
        }))
        
        present(alertController, animated: true)
    }
    
    //MARK: - Methods
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated:  true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("Failed to save people.")
        }
    }
}

