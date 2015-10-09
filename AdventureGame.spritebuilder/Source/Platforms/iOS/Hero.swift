//
//  Hero.swift
//  AdventureGame
//
//  Created by asu on 2015-10-09.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Hero : CCSprite {
    
    var crystalsCount:Int = 0
    var isJumping = false
    
    let jumpImpulse : CGFloat = 125

    
    func grabCrystal(){
        crystalsCount += 1
    }
    
    func jump(){
		physicsBody.applyImpulse(ccp(0, jumpImpulse))
        isJumping = true

		animationManager.runAnimationsForSequenceNamed("Leaping Timeline")
        
    }
    
    func landJump(){
        isJumping = false
        animationManager.runAnimationsForSequenceNamed("Running Timeline")
    }
    
    func die(){
        isJumping = false
        animationManager.runAnimationsForSequenceNamed("Running Timeline")
    }
}