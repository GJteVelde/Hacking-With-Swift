//
//  GameScene.swift
//  Project 23 Space Race
//
//  Created by Gerjan te Velde on 06/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer!
    var isGameOver = false {
        didSet {
            if isGameOver {
                physicsWorld.speed = 0.0
                starfield.isPaused = true
                gameTimer.invalidate()
            }
        }
    }
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.black
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.zPosition = -1
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        score = 0
        
        createPlayer()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 || node.position.x > 1324 {
                node.removeFromParent()
            }
        }
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let objects = nodes(at: location)

        for object in objects {
            if object.name == "player" {
                //createLaser(atLocation: CGPoint(x: player.position.x + 50, y: player.position.y))
                createLaser(atLocation: CGPoint(x: player.position.x, y: player.position.y))
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        //Player can only be moved if you touch & drag it.
        let objects = nodes(at: location)
        
        for object in objects {
            if object.name == "player" {
                if location.y < 100 {
                    location.y = 100
                } else if location.y > 668 {
                    location.y = 668
                }
                
                player.position = location
                break
            }
        }
    }
    
    //Game Over if user removes finger from screen
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//
//        let location = touch.location(in: self)
//
//        let explosion = SKEmitterNode(fileNamed: "explosion")!
//        explosion.position = location
//        addChild(explosion)
//
//        player.removeFromParent()
//
//        isGameOver = true
//    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "player" || contact.bodyB.node?.name == "player" {
            let explosion = SKEmitterNode(fileNamed: "explosion")!
            explosion.position = player.position
            addChild(explosion)
            
            player.removeFromParent()
            
            isGameOver = true
        } else if contact.bodyA.node?.name == "enemy" {
            let explosion = SKEmitterNode(fileNamed: "explosion")!
            explosion.position = contact.bodyA.node!.position
            addChild(explosion)
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "enemy" {
            let explosion = SKEmitterNode(fileNamed: "explosion")!
            explosion.position = contact.bodyB.node!.position
            addChild(explosion)
            
            contact.bodyB.node?.removeFromParent()
            contact.bodyA.node?.removeFromParent()
        }
    }
    
    @objc func createEnemy() {
        let enemy = SKSpriteNode(imageNamed: possibleEnemies.randomElement()!)
        enemy.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        enemy.name = "enemy"
        addChild(enemy)
        
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemy.physicsBody?.angularVelocity = 5
        enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.angularDamping = 0
        
        enemy.physicsBody?.categoryBitMask = UInt32(1)
        enemy.physicsBody?.collisionBitMask = 0 //enemy has no collisions
        enemy.physicsBody?.contactTestBitMask = UInt32(2) | UInt32(4) //notify about contact between enemy and laser or player
    }
    
    func createLaser(atLocation location: CGPoint) {
        let laser = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 10))
        laser.name = "laser"
        laser.position = location
        addChild(laser)

        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.velocity = CGVector(dx: 500, dy: 0)
        laser.physicsBody?.allowsRotation = false
        laser.physicsBody?.linearDamping = 0
        laser.physicsBody?.angularVelocity = 0
        laser.physicsBody?.angularDamping = 0
        
        laser.physicsBody?.categoryBitMask = UInt32(2)
        laser.physicsBody?.collisionBitMask = 0 //laser has no collisions
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.name = "player"
        player.position = CGPoint(x: 100, y: 384)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = false
        
        player.physicsBody?.categoryBitMask = UInt32(4)
        player.physicsBody?.collisionBitMask = 0 //player has no collisions
    }
}
