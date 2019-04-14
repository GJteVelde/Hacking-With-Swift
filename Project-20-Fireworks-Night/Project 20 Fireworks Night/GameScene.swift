//
//  GameScene.swift
//  Project 20 Fireworks Night
//
//  Created by Gerjan te Velde on 28/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: - Properties
    var gameTimer: Timer!
    var fireworks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var shakeLabel: SKLabelNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            
            if score > 100_000 {
                gameTimer.invalidate()
                scoreLabel.color = .red
            }
        }
    }
    
    //MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
        
        shakeLabel = SKLabelNode(fontNamed: "ChalkDuster")
        shakeLabel.fontSize = 48
        shakeLabel.position = CGPoint(x: 1016, y: 8)
        shakeLabel.horizontalAlignmentMode = .right
        shakeLabel.text = "Shake"
        shakeLabel.name = "Shake"
        addChild(shakeLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        scoreLabel.fontSize = 48
        scoreLabel.position = CGPoint(x: 512, y: 760)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    //MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        checkTouches(touches)
    }
    
    //MARK: - Methods
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if node is SKLabelNode {
                let label = node as! SKLabelNode
                if label.name == "Shake" {
                    explodeFireworks()
                }
            }
            
            if node is SKSpriteNode {
                let sprite = node as! SKSpriteNode
                if sprite.name == "firework" {
                    for parent in fireworks {
                        let firework = parent.children[0] as! SKSpriteNode
                        if firework.name == "selected" && firework.color != sprite.color {
                            firework.name = "firework"
                            firework.colorBlendFactor = 1
                        }
                    }
                    sprite.name = "selected"
                    sprite.colorBlendFactor = 0
                }
            }
        }
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...4) {
        case 0:
            //fire five, straight up
            for i in -2...2 {
                createFirework(xMovement: 0, xPosition: 512 + (i * 100), yPosition: bottomEdge)
            }
        case 1:
            //fire five, in a fan
            for i in -2...2 {
                createFirework(xMovement: CGFloat(i * 100), xPosition: 512 + (i * 100), yPosition: bottomEdge)
            }
        case 2:
            //fire five, from the left to the right
            for i in 0...4 {
                createFirework(xMovement: movementAmount, xPosition: leftEdge, yPosition: bottomEdge + (i * 100))
            }
        case 3:
            //fire five, from the right to the left
            for i in 0...4 {
                createFirework(xMovement: -movementAmount, xPosition: rightEdge, yPosition: bottomEdge + (i * 100))
            }
        case 4:
            //fire six, 3 from right and 3 from left
            for i in 0...2 {
                createFirework(xMovement: movementAmount, xPosition: leftEdge, yPosition: bottomEdge + (i * 100))
                createFirework(xMovement: -movementAmount, xPosition: rightEdge, yPosition: bottomEdge + (i * 100))
            }
        default:
            break
        }
    }
    
    func createFirework(xMovement: CGFloat, xPosition: Int, yPosition: Int) {
        let fireworkContainer = SKNode()
        fireworkContainer.position = CGPoint(x: xPosition, y: yPosition)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        firework.colorBlendFactor = 1
        fireworkContainer.addChild(firework)
        
        let randomColors: [UIColor] = [.cyan, .green, .red]
        firework.color = randomColors.randomElement()!
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        fireworkContainer.run(move)
        
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        fireworkContainer.addChild(emitter)
        
        fireworks.append(fireworkContainer)
        addChild(fireworkContainer)
    }
    
    func explode(firework: SKNode) {
        let emitter = SKEmitterNode(fileNamed: "explode")!
        emitter.position = firework.position
        addChild(emitter)
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            let firework = fireworkContainer.children[0] as! SKSpriteNode
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        case 5:
            score += 4000
        default:
            score += 6000
        }
    }
}
