//
//  ViewController.swift
//  Milestone 04 Hangman
//
//  Created by Gerjan te Velde on 22/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Objects and Properties
    @IBOutlet weak var missedCharactersLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var hangmanLabel: UILabel!
    @IBOutlet weak var characterTextField: UITextField!
    
    var words = ["rhythm", "swift", "monday", "summer", "hospital", "truck"]
    
    var missedCharacters = [Character]() {
        didSet {
            let missedCharactersAsString = missedCharacters.map { String($0) }
            let missedCharactersString = missedCharactersAsString.joined(separator: ", ")
            missedCharactersLabel.text = missedCharactersString
            
            updateHangman()
            
            if missedCharacters.count == 6 {
                gameOver()
            }
        }
    }
    
    var solution: String!
    var word: String! {
        didSet {
            var wordArray = [String]()
            for item in word {
                wordArray.append(String(item))
            }
            wordLabel.text = wordArray.joined(separator: " ")
        }
    }

    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Hangman"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewWord))
        characterTextField.delegate = self
        
        loadNewGame()
    }
    
    //MARK: - TextField Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text! + string
    
        guard text.count <= 1 else { return false }
        guard Character(text).isLetter else { return false }
        
        guard !missedCharacters.contains(Character(text)) else { return false }
        guard !word.contains(Character(text)) else { return false }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard !textField.text!.isEmpty else { return false }
        
        checkCharacter(character: Character(textField.text!.lowercased()))
        textField.text = ""
        return true
    }

    //MARK: - Methods
    func loadNewGame() {
        missedCharacters.removeAll(keepingCapacity: true)
        word = ""
        solution = words.randomElement()
        
        for _ in solution {
            word += "_"
        }
    }
    
    func checkCharacter(character: Character) {
        if solution.contains(character) {
            //Reveal character in word
            var wordCharacters = [Character]()
            for item in word {
                wordCharacters.append(item)
            }
            
            for (index, item) in solution.enumerated() {
                if item == character {
                    wordCharacters[index] = character
                }
            }
            word = wordCharacters.map { String($0) }.joined()
            
            if word == solution {
                win()
            }
        } else {
            missedCharacters.append(character)
        }
    }
    
    func updateHangman() {
        let hangman = [
            "",
            "o",
            "o\n|",
            "o\n |\\",
            "o\n/|\\",
            "o\n/|\\\n  \\",
            "o\n/|\\\n/ \\"
        ]
        
        let currentHangman = missedCharacters.count
        hangmanLabel.text = hangman[currentHangman]
    }
    
    @objc func addNewWord() {
        let alert = UIAlertController(title: "Add new word", message: "Remember words are randomly chosen.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter new word here..."
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [unowned self] (_) in
            if let newWord = alert.textFields?[0].text?.lowercased() {
                guard !newWord.isEmpty else { return }
                
                for letter in newWord {
                    if !letter.isLetter {
                        print("\(newWord) has not been added.")
                        return
                    }
                }
                
                self.words.append(newWord)
                print("\(newWord) has been added.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func gameOver() {
        let alert = UIAlertController(title: "Game Over", message: "The word was '\(solution!)'.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start new game", style: .default, handler: { [unowned self] (_) in
            self.loadNewGame()
        }))
        present(alert, animated: true)
    }
    
    func win() {
        let alert = UIAlertController(title: "Congrats!", message: "You have won!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start new game", style: .default, handler: { [unowned self] (_) in
            self.loadNewGame()
        }))
        present(alert, animated: true)
    }
}

