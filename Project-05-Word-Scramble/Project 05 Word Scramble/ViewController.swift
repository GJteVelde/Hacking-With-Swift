//
//  ViewController.swift
//  Project 05 Word Scramble
//
//  Created by Gerjan te Velde on 27/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    //MARK: - Objects
    var allWords = [String]()
    var usedWords = [String]()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
                //After the last item in start.txt there is a \n, which creates an empty string.
                allWords.removeAll { $0 == "" }
            } else {
                loadDefaultWords()
            }
        } else {
            loadDefaultWords()
        }
        
        startGame()
    }

    //MARK: - Table View DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    
    //MARK: - Methods
    func loadDefaultWords() {
        allWords = ["silkworm"]
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    @objc func promptForAnswer() {
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, alertController] (action: UIAlertAction) in
            let answer = alertController.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isNotWord(word: lowerAnswer) {
            if isPossible(word: lowerAnswer) {
                if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        if isLong(word: lowerAnswer) {
                            usedWords.insert(answer, at: 0)
                            
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            return
                        } else {
                            showErrorMessage(title: "Word too short", message: "Can't you come up with something longer?")
                        }
                    } else {
                        showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
                    }
                } else {
                    showErrorMessage(title: "Word used already", message: "Be more original!")
                }
            } else {
                showErrorMessage(title: "Word not possible", message: "You can't spell that word from '\(title!.lowercased())'!")
            }
        } else {
            showErrorMessage(title: "Word not allowed", message: "Really? Submitting '\(title!.lowercased())' is too easy!")
        }
    }
    
    func showErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    func isNotWord(word: String) -> Bool {
        return word != title!.lowercased()
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()
        
        for letter in word {
            if let position = tempWord.range(of: String(letter)) {
                tempWord.remove(at: position.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLong(word: String) -> Bool {
        let range = NSMakeRange(0, word.utf16.count)
        return range.length >= 3
    }
}

