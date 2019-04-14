//
//  GameScene.swift
//  Project 17 Swifty Ninja
//
//  Created by Gerjan te Velde on 13/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene {
   
    //MARK: - Properties
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var activeEnemies = [SKSpriteNode]()
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBackground: SKShapeNode!
    var activeSliceForeground: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    
    var isSwooshSoundActive = false
    var bombSoundEffect: AVAudioPlayer!
    
    var isBonusLabelActive = false
    var bonusLabel: SKLabelNode!
    
    var popUpTime = 0.9
    var sequence: [SequenceType]!
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var gameEnded = false
    
    //MARK: - Scene Life Cycle
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        createBonus()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0 ... 1000 {
            let nextSequence = SequenceType.allCases.randomElement()!
            sequence.append(nextSequence)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.tossEnemies()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for node in activeEnemies {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" || node.name == "bonusEnemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        
                        if let index = activeEnemies.index(of: node) {
                            activeEnemies.remove(at: index)
                        }
                    } else if node.name == "bombContainer" {
                            node.name = ""
                            node.removeFromParent()
                            
                        if let index = activeEnemies.index(of: node) {
                            activeEnemies.remove(at: index)
                        }
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popUpTime) { [unowned self] in
                    self.tossEnemies()
                }
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
        }

        var bonusCount = 0
        for node in activeEnemies {
            if node.name == "bonusEnemy" {
                bonusCount += 1
                break
            }
        }
        
        if bonusCount == 0 {
            isBonusLabelActive = false
            pulseBonus(false)
        }
    }
    
    //MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            activeSlicePoints.append(location)
        }
        
        redrawActiveSlice()
        
        activeSliceBackground.removeAllActions()
        activeSliceForeground.removeAllActions()
        
        activeSliceBackground.alpha = 1
        activeSliceForeground.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameEnded {
            return
        }
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            if node.name == "enemy" || node.name == "bonusEnemy" {
                let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy")!
                emitter.position = node.position
                addChild(emitter)
                
                if node.name == "bonusEnemy" {
                    score += 5
                } else {
                    score += 1
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.02)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
                node.run(sequence)
                
                let index = activeEnemies.index(of: node as! SKSpriteNode)!
                activeEnemies.remove(at: index)
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "bomb" {
                let emitter = SKEmitterNode(fileNamed: "sliceHitBomb")!
                emitter.position = node.parent!.position
                addChild(emitter)
                
                node.name = ""
                node.parent?.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadOut])
                
                let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
                
                node.parent?.run(sequence)
                
                let index = activeEnemies.index(of: node.parent as! SKSpriteNode)!
                activeEnemies.remove(at: index)
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBackground.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceForeground.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    //MARK: - Methods
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        gameScore.position = CGPoint(x: 8, y: 8)
        
        addChild(gameScore)
    }
    
    func createLives() {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBackground = SKShapeNode()
        activeSliceBackground.zPosition = 2
        activeSliceBackground.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBackground.lineWidth = 9
        addChild(activeSliceBackground)
        
        activeSliceForeground = SKShapeNode()
        activeSliceForeground.zPosition = 2
        activeSliceForeground.strokeColor = UIColor.white
        activeSliceForeground.lineWidth = 5
        addChild(activeSliceForeground)
    }
    
    func createBonus() {
        bonusLabel = SKLabelNode(fontNamed: "Chalkduster")
        bonusLabel.text = "Get your bonuspoints!"
        bonusLabel.horizontalAlignmentMode = .center
        bonusLabel.fontColor = UIColor.red
        bonusLabel.fontSize = 30
        bonusLabel.position = CGPoint(x: 512, y: 8)
        bonusLabel.alpha = 0
        addChild(bonusLabel)
    }
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBackground.path = nil
            activeSliceForeground.path = nil
            return
        }
        
        while activeSlicePoints.count > 12 {
            activeSlicePoints.remove(at: 0)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBackground.path = path.cgPath
        activeSliceForeground.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [unowned self] in
            self.isSwooshSoundActive = false
        }
    }
    
    func pulseBonus(_ pulse: Bool) {
        if isBonusLabelActive {
            return
        }
        
        if pulse {
            isBonusLabelActive = true
            
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let pulseOnce = SKAction.sequence([fadeIn, fadeOut])
            let pulse = SKAction.repeatForever(pulseOnce)
            
            bonusLabel.run(pulse)
        } else {
            isBonusLabelActive = false
            bonusLabel.removeAllActions()
            bonusLabel.alpha = 0
        }
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        var enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
            
            let path = Bundle.main.path(forResource: "sliceBombFuse.caf", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            bombSoundEffect = try! AVAudioPlayer(contentsOf: url)
            bombSoundEffect.play()
            
            let emitter = SKEmitterNode(fileNamed: "sliceFuse")!
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
        } else if enemyType == 6 {
            enemy = SKSpriteNode(imageNamed: "bonusPenguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "bonusEnemy"
            pulseBonus(true)
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        let randomAngularVelocity = CGFloat.random(in: -6...6) / 2.0
        
        let randomXSlowVelocity = Int.random(in: 3...5)
        let randomXFastVelocity = Int.random(in: 8...15)
        
        var randomXVelocity = 0
        if randomPosition.x < 256 {
            randomXVelocity = randomXFastVelocity
        } else if randomPosition.x < 512 {
            randomXVelocity = randomXSlowVelocity
        } else if randomPosition.x < 768 {
            randomXVelocity = -randomXSlowVelocity
        } else {
            randomXVelocity = -randomXFastVelocity
        }
        
        let randomYVelocity = Int.random(in: 24...32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func tossEnemies() {
        if gameEnded {
            return
        }
        
        popUpTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [unowned self] in
                self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [unowned self] in
                self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [unowned self] in
                self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [unowned self] in
                self.createEnemy()
            }
            
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [unowned self] in
                self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [unowned self] in
                self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [unowned self] in
                self.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [unowned self] in
                self.createEnemy()
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
    
    func endGame(triggeredByBomb: Bool) {
        if gameEnded {
            return
        }
        
        gameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }
        
        if isBonusLabelActive {
            pulseBonus(false)
        }
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
    
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
}
