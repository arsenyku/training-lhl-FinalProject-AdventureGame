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

enum MoveDirection:Float,CustomStringConvertible {
    case Up = -90
    case Down = 90
    case Left = 180
    case Right = 0
    case None = 360
    
    var description: String{
        get{
            switch(self){
            case Up:
                return "Up"
            case Down:
                return "Down"
            case .Left:
                return "Left"
            default:
                return "Right"
            }
        }
    }
    
    var angle: Float{
        return self.rawValue
    }
    
    func angleForBend(endDirection endDirection:MoveDirection) -> Float{
        switch(self){
        case Up:
            if (endDirection == .Left) { return 0 }
            else { return -90 }
        case Down:
            if (endDirection == .Left) { return 90 }
            else { return 180 }
        case Left:
            if (endDirection == .Up) { return 180 }
            else { return -90 }
        case Right:
            if (endDirection == .Up) { return 90 }
            else { return 0 }
        default:
            return 0
        }
    }
    
    static func direction(from from:CGPoint, to:CGPoint) -> (horizontal:MoveDirection, vertical:MoveDirection){
        var vertical, horizontal: MoveDirection
        
        if (from.x < to.x) { horizontal = .Right }
        else if (from.x > to.x) { horizontal = .Left }
        else { horizontal = .None }
        
        if (from.y < to.y) { vertical = .Up }
        else if (from.y > to.y) { vertical = .Down }
        else { vertical = .None }
        
        print ("from \(from) to \(to)    hresult \(horizontal)  vresult\(vertical)")
        return (horizontal, vertical)
    }
    
    static func turnAction(from startDirection:MoveDirection, to endDirection:MoveDirection) -> CCActionRotateTo? {
        let turnDuration:CCTime = 0.1
        let result = CCActionRotateTo.actionWithDuration(turnDuration, angle: endDirection.angle) as! CCActionRotateTo
        
        return result
    }
}

class SnakePart : CCSprite {

    var partType: PartType = .Body
    var forward: MoveDirection = .Right
    weak var frontPart: SnakePart?
    weak var snake: Snake!
    
    func moveToNextTile(){

        if let next = snake.tileMap.nextTile(forSprite: self, inDirection: forward) {
            position = next.origin
            let previousForward = forward
            forward = snake.tileMap.direction(from: position, to: frontPart!.position)
            rotation = forward.angle
            
            if partType == .Tail {
            	rotation = forward.angle
                
            } else if previousForward == forward {
                // Going in the same direction as before
                self.spriteFrame = straightImage()
                rotation = forward.angle
            } else {
                // Right angle turn
                self.spriteFrame = bentImage()
                rotation = previousForward.angleForBend(endDirection: forward)
                
            }
            
        }

    }
    
    func bentImage() -> CCSpriteFrame{
        let result = CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName(Snake.bentBodyImage)
        return result
    }
    
    func straightImage() -> CCSpriteFrame {
        let result = CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName(Snake.normalBodyImage)
        return result
    }
    
    class func spawn(type type:PartType = .Body) -> SnakePart{
        var partName:String
        var snakePart:SnakePart
        switch (type) {
        case .Head:
	        partName = "SnakeHead"
            snakePart =  CCBReader.load(partName) as! SnakeHead

        case .Tail:
            partName = "SnakeTail"
            snakePart =  CCBReader.load(partName) as! SnakePart

        default:
            partName = "SnakeBody"
            snakePart =  CCBReader.load(partName) as! SnakePart

        }
        
        snakePart.partType = type
        snakePart.scale = 2
        snakePart.positionType.corner = .TopLeft

        
        return snakePart
    }
    
    
    func rollD100(successChance chance:Int = 50) -> Bool {
        return Float.random(min: 0, max: 1, precision:2) < (Float(chance)/100)
    }

}


