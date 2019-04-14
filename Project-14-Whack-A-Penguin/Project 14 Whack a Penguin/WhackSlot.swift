//
//  WhackSlot.swift
//  Project 14 Whack a Penguin
//
//  Created by Gerjan te Velde on 10/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    
    var isVisible = false
    var isHit = false
    
    var characterNode: SKSpriteNode!

    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        characterNode = SKSpriteNode(imageNamed: "penguinGood")
        characterNode.position = CGPoint(x: 0, y: -90)
        characterNode.name = "character"
        cropNode.addChild(characterNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        if isHit { return }
        
        characterNode.xScale = 1
        characterNode.yScale = 1
        
        isVisible = true
        
        let mud = SKEmitterNode(fileNamed: "Mud.sks")
        mud!.position = CGPoint(x: 0, y: 15)
        addChild(mud!)
        
        characterNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        
        if Int.random(in: 0...2) == 0 {
            characterNode.texture = SKTexture(imageNamed: "penguinGood")
            characterNode.name = "characterFriend"
        } else {
            characterNode.texture = SKTexture(imageNamed: "penguinEvil")
            characterNode.name = "characterEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [unowned self] in
            self.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        if isHit { return }

        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.05)
        let notVisible = SKAction.run { [unowned self] in
            self.isVisible = false
        }
        
        characterNode.run(SKAction.sequence([hide, notVisible]))
    }
    
    func hit() {
        isHit = true
        
        let smoke = SKEmitterNode(fileNamed: "Smoke.sks")
        smoke!.position = CGPoint(x: 0, y: 15)
        addChild(smoke!)
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [unowned self] in
            self.isHit = false
            self.isVisible = false
        }
        
        characterNode.run(SKAction.sequence([delay, hide, notVisible]))
    }
}
