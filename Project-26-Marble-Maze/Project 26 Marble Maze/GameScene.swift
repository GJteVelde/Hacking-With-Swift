//
//  GameScene.swift
//  Project 26 Marble Maze
//
//  Created by Gerjan te Velde on 10/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleporterStart = 32
    case teleporterEnd = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var motionManager: CMMotionManager!
    
    var levelLabel: SKLabelNode!
    var level = 1 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gamePieces = [SKNode]()
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        loadLevel()
        createPlayer()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        levelLabel.text = "Level: 1"
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.position = CGPoint(x: 1008, y: 16)
        levelLabel.zPosition = 1
        addChild(levelLabel)
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == player {
            playerCollided(with: contact.bodyB.node!)
        } else if contact.bodyB.node == player {
            playerCollided(with: contact.bodyA.node!)
        }
    }
    
    func loadLevel() {
        if let levelPath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") {
            if let levelString = try? String(contentsOfFile: levelPath) {
                var lines = levelString.components(separatedBy: "\n")
                if lines.last!.isEmpty {
                    lines.removeLast()
                }
                for (row, line) in lines.reversed().enumerated() {
                    for (column, letter) in line.enumerated() {
                        let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                        
                        if letter == "x" {
                            createBlock(at: position)
                        } else if letter == "v" {
                            createVortex(at: position)
                        } else if letter == "s" {
                            createStar(at: position)
                        } else if letter == "f" {
                            createFinish(at: position)
                        } else if letter == "t" {
                            createTeleporterStart(at: position)
                        } else if letter == "o" {
                            createTeleporterEnd(at: position)
                        }
                    }
                }
            }
        }
    }
    
    func createBlock(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        addChild(node)
        gamePieces.append(node)
    }
    
    func createVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1)))
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        addChild(node)
        gamePieces.append(node)
    }
    
    func createTeleporterStart(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "teleporterStart"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: -CGFloat.pi, duration: 1)))
        node.color = UIColor.green
        node.colorBlendFactor = 1
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.teleporterStart.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        addChild(node)
        gamePieces.append(node)
    }
    
    func createTeleporterEnd(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "player")
        node.name = "teleporterEnd"
        node.position = position
        node.color = UIColor.black
        node.colorBlendFactor = 1
        
        addChild(node)
        gamePieces.append(node)
    }
    
    func createStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.isDynamic = false
        addChild(node)
        gamePieces.append(node)
    }
    
    func createFinish(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = false
        addChild(node)
        gamePieces.append(node)
    }
    
    func createPlayer(at position: CGPoint = CGPoint(x: 96, y: 672)) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.name = "player"
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.setScale(0)
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.teleporterStart.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
        
        player.run(SKAction.scale(to: 1, duration: 0.25)) { [unowned self] in
            self.player.physicsBody?.isDynamic = true
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let movePlayer = SKAction.move(to: node.position, duration: 0.5)
            let scalePlayer = SKAction.scale(to: 0, duration: 0.5)
            let suckedInPlayer = SKAction.group([movePlayer, scalePlayer])
            
            player.run(suckedInPlayer) { [unowned self] in
                self.player.removeFromParent()
                self.createPlayer()
                self.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "teleporterStart" {
            let teleporterEnds = gamePieces.filter { $0.name == "teleporterEnd" }
            
            if let teleporterEnd = teleporterEnds.randomElement() {
                let movePlayer = SKAction.move(to: node.position, duration: 0.5)
                let scalePlayer = SKAction.scale(to: 0, duration: 0.5)
                let suckedInPlayer = SKAction.group([movePlayer, scalePlayer])
                
                player.run(suckedInPlayer) { [unowned self] in
                    self.player.removeFromParent()
                    self.createPlayer(at: teleporterEnd.position)
                }
            }
        } else if node.name == "finish" {
            player.removeFromParent()
            score += 10
            
            if level == 2 {
                level = 1
            } else {
                level += 1
            }
            
            for piece in gamePieces {
                piece.removeFromParent()
            }
            
            loadLevel()
            createPlayer()
        }
    }
}
