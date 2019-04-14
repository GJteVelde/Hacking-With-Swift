//
//  ViewController.swift
//  Project 08 7 Swifty Words
//
//  Created by Gerjan te Velde on 02/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet var cluesLabel: UILabel!
    @IBOutlet var answersLabel: UILabel!
    @IBOutlet var currentAnswer: UITextField!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    //MARK: - Properties
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]() //Holds all buttons the player tapped before submitting the answer.
    var solutions = [String]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var correctAnswerScore = 0
    var level = 1
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subview in containerView.subviews where subview.tag == 1001 {
            let button = subview as! UIButton
            letterButtons.append(button)
            button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        
        loadLevel()
    }
    
    //MARK: - Methods
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        guard let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") else { return }
        guard let levelContents = try? String(contentsOfFile: levelFilePath) else { return }
        
        var lines = levelContents.components(separatedBy: "\n")
        lines.shuffle()
        
        for (index, line) in lines.enumerated() {
            let parts = line.components(separatedBy: ": ")
            let answer = parts[0]
            let clue = parts[1]
            
            clueString += "\(index + 1). \(clue)\n"
            
            let solutionWord = answer.replacingOccurrences(of: "|", with: "")
            solutionString += "\(solutionWord.count) letters\n"
            solutions.append(solutionWord)
            
            let bits = answer.components(separatedBy: "|")
            letterBits += bits
        }
        
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterBits.shuffle()
        
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
                letterButtons[i].alpha = 1
            }
        }
    }
    
    @objc func letterTapped(button: UIButton) {
        currentAnswer.text = currentAnswer.text! + button.titleLabel!.text!
        activatedButtons.append(button)
        
        UIView.animate(withDuration: 1) {
            button.alpha = 0
        }
    }
    
    func levelUp(_ action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
    }

    //MARK: - Actions
    @IBAction func submitTouchUpInside(_ sender: UIButton) {
        if let solutionPosition = solutions.index(of: currentAnswer.text!) {
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text!.components(separatedBy: "\n")
            splitAnswers[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitAnswers.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            correctAnswerScore += 1
            
            if correctAnswerScore % 7 == 0 {
                let alertController = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(alertController, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "Wrong!", message: "We subtract 1 point.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Try again!", style: .default, handler: { (_) in
                self.score -= 1
            }))
            present(alertController, animated: true)
        }
    }
    
    @IBAction func clearTouchUpInside(_ sender: UIButton) {
        currentAnswer.text = ""
        
        for button in activatedButtons {
            button.alpha = 1
        }
        
        activatedButtons.removeAll()
    }
    
}

