//
//  ViewController.swift
//  Project 37 Psychic Tester
//
//  Created by Gerjan te Velde on 11/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import AVFoundation
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    //MARK: - Objects and Properties
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var gradientView: GradientView!
    
    var allCards = [CardViewController]()
    var music: AVAudioPlayer!
    var connectivitySound: AVAudioPlayer!
    var lastMessage: CFAbsoluteTime = 0
    var winningMode = false
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        view.backgroundColor = UIColor.red
        UIView.animate(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
            self.view.backgroundColor = UIColor.blue
        })
        
        createParticles()
        loadCards()
        playMusic()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let instructions = "Please ensure your Apple Watch is configured correctly. On your iPhone, launch Apple's 'Watch' configuration app then choose General > Wake Screen. On that screen, please disable Wake Screen On Wrist Raise, then select Wake for 70 seconds. On your Apple Watch, please swipe up on your watch face and enable Silent Mode. You're Done!"
        
        let alert = UIAlertController(title: "Adjust your settings", message: instructions, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'm Ready", style: .default))
        present(alert, animated: true)
    }

    //MARK: - Methods
    @objc func loadCards() {
        for card in allCards {
            card.view.removeFromSuperview()
            card.removeFromParent()
        }
        
        allCards.removeAll(keepingCapacity: true)
        
        let positions = [
            CGPoint(x: 75, y: 85),
            CGPoint(x: 185, y: 85),
            CGPoint(x: 295, y: 85),
            CGPoint(x: 405, y: 85),
            CGPoint(x: 75, y: 235),
            CGPoint(x: 185, y: 235),
            CGPoint(x: 295, y: 235),
            CGPoint(x: 405, y: 235)
        ]
        
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!
        
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()
        
        for (index, position) in positions.enumerated() {
            let card = CardViewController()
            card.delegate = self
            
            addChild(card)
            cardContainer.addSubview(card.view)
            card.didMove(toParent: self)
            
            card.view.center = position
            card.front.image = images[index]
            
            if card.front.image == star {
                card.isCorrect = true
            }
            
            allCards.append(card)
        }
        
        view.isUserInteractionEnabled = true
    }
    
    func cardTapped(_ tapped: CardViewController) {
        guard view.isUserInteractionEnabled == true else { return }
        view.isUserInteractionEnabled = false
        
        for card in allCards {
            if card == tapped {
                card.wasTapped()
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1)
            } else {
                card.wasntTapped()
            }
        }
        
        perform(#selector(loadCards), with: nil, afterDelay: 2)
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2, y: -50)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1)
        particleEmitter.renderMode = .additive
        
        let emitterCell = CAEmitterCell()
        
        emitterCell.birthRate = 2
        emitterCell.lifetime = 5.0
        emitterCell.velocity = 100
        emitterCell.velocityRange = 50
        emitterCell.emissionLongitude = .pi
        emitterCell.spinRange = 5
        emitterCell.scale = 0.5
        emitterCell.scaleRange = 0.25
        emitterCell.color = UIColor(white: 1, alpha: 0.1).cgColor
        emitterCell.alphaSpeed = -0.025
        emitterCell.contents = UIImage(named: "particle")?.cgImage
        
        particleEmitter.emitterCells = [emitterCell]
        
        gradientView.layer.addSublayer(particleEmitter)
    }
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                music = audioPlayer
                music.numberOfLoops = -1
                music.play()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer)
        
        for card in allCards {
            if card.view.frame.contains(location) {
                if winningMode {
                    card.front.image = UIImage(named: "cardStar")
                    card.isCorrect = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer)
        
        for card in allCards {
            if card.view.frame.contains(location) {
                
                if view.traitCollection.forceTouchCapability == .available {
                    if touch.force == touch.maximumPossibleForce {
                        card.front.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    }
                }
                
                if card.isCorrect {
                    sendWatchMessage()
                }
                
                if winningMode {
                    card.front.image = UIImage(named: "cardStar")
                    card.isCorrect = true
                }
            }
        }
    }
    
    func playWatchConnectivitySound(isConnected connected: Bool) {
        var soundURL: URL!
        
        if connected {
            soundURL = Bundle.main.url(forResource: "launch", withExtension: "caf")
        } else {
            soundURL = Bundle.main.url(forResource: "explosion", withExtension: "caf")
        }
        
        if let soundPlayer = try? AVAudioPlayer(contentsOf: soundURL) {
            connectivitySound = soundPlayer
            connectivitySound.volume = 0.2
            connectivitySound.play()
        } else {
            print("playWatchConnectivitySound(): Could not play sound")
        }
    }
    
    //MARK: - WatchConnectivity (Delegate) Methods
    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if lastMessage + 0.5 > currentTime {
            return
        }
        
        if (WCSession.default.isReachable) {
            let message = ["Message": "Hello"]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
        
        lastMessage = CFAbsoluteTimeGetCurrent()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if !session.isReachable {
            playWatchConnectivitySound(isConnected: false)
        } else if session.isReachable {
            playWatchConnectivitySound(isConnected: true)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let winningModeMessage = message["winningMode"] as? Bool {
            winningMode = winningModeMessage
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}

