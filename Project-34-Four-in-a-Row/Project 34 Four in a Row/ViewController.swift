//
//  ViewController.swift
//  Project 34 Four in a Row
//
//  Created by Gerjan te Velde on 01/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    //MARK: - Properties and Objects
    @IBOutlet var columnButtons: [UIButton]!
    
    var placedChips = [[UIView]]()
    var board: Board!
    
    var barButtonTitle = "Two Players"
    var barButtonMessage: String? = "Ready to kick your friend's ass?"
    
    var difficulty = 7
    
    var playAgainstAI = true {
        didSet {
            if playAgainstAI {
                barButtonTitle = "Two Players"
                barButtonMessage = "Ready to kick your friend's ass?"
            } else {
                barButtonTitle = "One Player"
                barButtonMessage = "How hard should your opponent be?"
            }
        }
    }
    
    var strategist: GKMinmaxStrategist!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        
        strategist = GKMinmaxStrategist()
        strategist.randomSource = GKARC4RandomSource()
        
        resetBoard()
    }
    
    //MARK: - Methods
    func resetBoard() {
        board = Board()
        strategist.gameModel = board
        strategist.maxLookAheadDepth = difficulty
        updateUI()
        
        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }
            
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }
    
    @objc func startNewGame() {
        let alert = UIAlertController(title: barButtonMessage, message: "A new game will be started.", preferredStyle: .alert)
        
        playAgainstAI = !playAgainstAI
        if playAgainstAI {
            alert.addAction(UIAlertAction(title: "Easy", style: .default, handler: { [unowned self] (action) in
                self.difficulty = 1
                self.resetBoard()
            }))
            alert.addAction(UIAlertAction(title: "Medium", style: .default, handler: { [unowned self] (action) in
                self.difficulty = 4
                self.resetBoard()
            }))
            alert.addAction(UIAlertAction(title: "Hard", style: .default, handler: { [unowned self] (action) in
                self.difficulty = 7
                self.resetBoard()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [unowned self] (action) in
                self.resetBoard()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] (action) in
            self.playAgainstAI = !self.playAgainstAI
        }))
        
        present(alert, animated: true)
    }
    
    func addChip(inColumn column: Int, row: Int, color: UIColor) {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        if (placedChips[column].count < row + 1) {
            let newChip = UIView()
            newChip.frame = rect
            newChip.isUserInteractionEnabled = false
            newChip.layer.cornerRadius = size / 2
            newChip.center = positionForChip(inColumn: column, row: row)
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)
            
            let chipImageView = UIImageView()
            chipImageView.frame = rect
            chipImageView.backgroundColor = .white
            
            if color == .red {
                chipImageView.image = UIImage(named: "RedChip.png")
            } else {
                chipImageView.image = UIImage(named: "BlackChip.png")
            }
            
            newChip.addSubview(chipImageView)
            
            view.addSubview(newChip)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                newChip.transform = CGAffineTransform.identity
            })
            
            placedChips[column].append(newChip)
        }
    }
    
    func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        
        let xOffset = button.frame.midX
        var yOffset = button.frame.maxY - size / 2
        yOffset -= size * CGFloat(row)
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    func updateUI() {
        title = "\(board.currentPlayer.name)'s Turn"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: barButtonTitle, style: .plain, target: self, action: #selector(startNewGame))
        
        view.backgroundColor = board.currentPlayer.color
        
        if board.currentPlayer.chip == .black && playAgainstAI {
            startAIMove()
        }
    }
    
    func continueGame() {
        var gameOverTitle: String? = nil
        
        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        } else if board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] (action) in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            
            return
        }
        
        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }
    
    func columnForAIMove() -> Int? {
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }
        
        return nil
    }
    
    func makeAIMove(in column: Int) {
        columnButtons.forEach { $0.isEnabled = true }
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            
            continueGame()
        }
    }
    
    func startAIMove() {
        columnButtons.forEach { $0.isEnabled = false }
        
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let column = self.columnForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                self.makeAIMove(in: column)
            })
        }
    }
    
    //MARK: - Actions
    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            continueGame()
        }
    }
}

