//
//  SnakePart.swift
//  AdventureGame
//
//  Created by asu on 2015-10-14.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

enum PartType {
    case Head
    case Body
    case Tail
}


class SnakePart : CCSprite {

    var partType: PartType = .Body

    
    func moveTo(point point:CGPoint, completion: () -> Void) {
 
        let movementVector = ccpSub(point, position)
        let deltaXSquared = pow(movementVector.x, 2)
        let deltaYSquared = pow(movementVector.y, 2)
        let magnitude = sqrt( deltaXSquared + deltaYSquared )
        let duration = Double(magnitude) / Snake.travelDistancePerSecond
        
        print ("magnitude \(magnitude), duration \(duration)")
        
        let moveTo = CCActionMoveTo.actionWithDuration(duration, position: point) as! CCAction
        let done = CCActionCallBlock { () -> Void in
            completion()
        }
        let runTo = CCActionSequence.actionWithArray([moveTo, done]) as! CCActionSequence

        runAction(runTo)
    }

    class func spawn(type type:PartType = .Body) -> SnakePart{
        var partName:String
        switch (type) {
        case .Head:
	        partName = "SnakeHead"
        case .Tail:
            partName = "SnakeTail"
        default:
            partName = "SnakeBody"
        }
        
        let snakePart =  CCBReader.load(partName) as! SnakePart
        snakePart.partType = type
        snakePart.scale = 1.75
        snakePart.positionType.corner = .TopLeft

        
        return snakePart
    }

}
