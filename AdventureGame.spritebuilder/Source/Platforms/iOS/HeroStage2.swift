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
    
    func moveTo(point point:CGPoint, immediate:Bool = true){
        
        let timeScaleFactor:Double = 200
        
        if immediate {
            stopAllActions()
        }
        
        let movementVector = ccpSub(point, position)
        let deltaXSquared = pow(movementVector.x, 2)
        let deltaYSquared = pow(movementVector.y, 2)
        let magnitude = sqrt( deltaXSquared + deltaYSquared )
        let duration = Double(magnitude) / timeScaleFactor
        
        print ("magnitude \(magnitude)")
        
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
    
    
    
}
