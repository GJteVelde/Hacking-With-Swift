//
//  GameScene.swift
//  Project 11 Pachinko
//
//  Created by Gerjan te Velde on 05/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Objects
    var scoreLabel: SKLabelNode!
    var ballsLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    
    var topBoxLine: SKSpriteNode!
    var bottomBoxLine: SKSpriteNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var balls = 5 {
        willSet {
            if newValue < 0 {
                //TODO: Implement Game-Over scene.
                fatalError()
            }
        }
        didSet {
            ballsLabel.text = "Balls left: \(balls)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            let glows = scene?.children.filter { $0.name == "glow" }
            if editingMode {
                editLabel.text = "Done"
                
                topBoxLine.isHidden = false
                bottomBoxLine.isHidden = false
                
                for glow in glows! {
                    glow.isPaused = true
                }
            } else {
                editLabel.text = "Edit"
                
                topBoxLine.isHidden = true
                bottomBoxLine.isHidden = true
                
                for glow in glows! {
                    glow.isPaused = false
                }
            }
        }
    }
    
    //MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        topBoxLine = SKSpriteNode(color: UIColor.red, size: CGSize(width: 1024, height: 10))
        topBoxLine.position = CGPoint(x: 512, y: 595)
        topBoxLine.isHidden = true
        addChild(topBoxLine)
        
        bottomBoxLine = SKSpriteNode(color: UIColor.red, size: CGSize(width: 1024, height: 10))
        bottomBoxLine.position = CGPoint(x: 512, y: 145)
        bottomBoxLine.isHidden = true
        addChild(bottomBoxLine)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls left: 5"
        ballsLabel.horizontalAlignmentMode = .center
        ballsLabel.position = CGPoint(x: 512, y: 700)
        addChild(ballsLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
    }
    
    //MARK: - Game Scene creation methods
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotGlow.name = "glow"
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    //MARK: - Game Play methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var location = touch.location(in: self)
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    let boxes = objects.filter { $0.name == "box" }
                    
                    if !boxes.isEmpty {
                        boxes.first?.removeFromParent()
                    } else {
                        if location.y < 145 || location.y > 600 {
                            return
                        }
                        let size = CGSize(width: Int.random(in: 16...128), height: 16)
                        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                        box.zRotation = CGFloat.random(in: 0...3)
                        
                        box.position = location
                        box.name = "box"
                        
                        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                        box.physicsBody?.isDynamic = false
                        
                        addChild(box)
                    }
                } else {
                    let balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
                    let randomNumber = Int.random(in: 0..<balls.count)
                    
                    let ball = SKSpriteNode(imageNamed: balls[randomNumber])
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody?.restitution = 0.4
                    
                    if location.y < 600 {
                        location.y = 600
                    }
                    
                    ball.position = location
                    ball.name = "ball"
                    
                    self.balls -= 1
                    addChild(ball)
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            balls += 1
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "box" {
            destroy(ball: object)
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
}
