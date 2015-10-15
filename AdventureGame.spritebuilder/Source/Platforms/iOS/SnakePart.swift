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
 
        var vector1, vector2: CGPoint
        
        let verticalFirst:Bool = rollD100()
        if verticalFirst {
            vector1 = ccp(position.x, point.y)
        } else {
            vector1 = ccp(point.x, position.y)
        }
        vector2 = ccp(point.x, point.y)

        print("move from \(position) to p1 \(vector1) to p2 \(vector2)")
        
        let movement1 = ccpSub(position, vector1)
        let movement2 = ccpSub(vector1, vector2)

        let totalTravelDistance = movement1.magnitude() + movement2.magnitude()
        let totalDuration = Double(totalTravelDistance) / Snake.travelDistancePerSecond
	
        if totalTravelDistance == 0 {
			completion()
            return
        }
        
        
        let portion1 = movement1.magnitude()/totalTravelDistance
        let portion2 = movement2.magnitude()/totalTravelDistance
        
        
        let move1 = CCActionMoveTo.actionWithDuration(portion1 * totalDuration, position: vector1) as! CCAction
        let move2 = CCActionMoveTo.actionWithDuration(portion2 * totalDuration, position: vector2) as! CCAction
        let done = CCActionCallBlock { () -> Void in
            completion()
        }
        let runTo = CCActionSequence.actionWithArray([move1, move2, done]) as! CCActionSequence

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
    
    
    func rollD100(successChance chance:Int = 50) -> Bool {
        return Float.random(min: 0, max: 1, precision:2) < (Float(chance)/100)
    }

}
