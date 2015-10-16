//
//  Hero+Stage2.swift
//  AdventureGame
//
//  Created by asu on 2015-10-13.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class HeroStage2 : Hero {

    var facingLeft:Bool = false
    
    func flipDirection(){
		facingLeft = !facingLeft
        flipX = facingLeft
    }
    
    func moveTo(point point:CGPoint){
        
        // Distance traveled by the hero in 1 second (rough estimate)
        let timeScaleFactor:Double = 220
        
        stopAllActions()
        
        let movementVector = ccpSub(point, position)
        let deltaXSquared = pow(movementVector.x, 2)
        let deltaYSquared = pow(movementVector.y, 2)
        let magnitude = sqrt( deltaXSquared + deltaYSquared )
        let duration = Double(magnitude) / timeScaleFactor
        
        let moveTo = CCActionMoveTo.actionWithDuration(duration, position: point) as! CCAction
        let done = CCActionCallBlock { () -> Void in
            self.playAnimation(named: "Standing Timeline")
        }
        let runTo = CCActionSequence.actionWithArray([moveTo, done]) as! CCActionSequence

        playAnimation(named: "Running Timeline")
        runAction(runTo)
        
        let needsToFlip = (point.x < position.x && !facingLeft) || (point.x > position.x && facingLeft)
        
        if needsToFlip {
            flipDirection()
        }
                
    }
    
    override func hitByEnemy(enemy: CCSprite) {
        if hasWon || isDead {
            return
        }
        
        if let snake = enemy as? SnakePart {
            if snake.partType == .Head {
                hitPoints -= 5
            } else {
                hitPoints -= 1
            }
        }
        
        if hitPoints < 1 {
            die(withAnimation: "Death Timeline")
        }

    }
    
}
