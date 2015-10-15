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
    
    static func direction(from from:CGPoint, to:CGPoint) -> (horizontal:MoveDirection, vertical:MoveDirection){
        var vertical, horizontal: MoveDirection
        
        if (from.x < to.x) { horizontal = .Right }
        else if (from.x > to.x) { horizontal = .Left }
        else { horizontal = .Left }
        
        if (from.y < to.y) { vertical = .Up }
        else if (from.y > to.y) { vertical = .Down }
        else { vertical = .Down }
        
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
    var direction: MoveDirection = .Right
    
    func moveTo(point destination:CGPoint, completion: () -> Void) {
 
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
        snakePart.scale = 1.75
        snakePart.positionType.corner = .TopLeft

        
        return snakePart
    }
    
    
    func rollD100(successChance chance:Int = 50) -> Bool {
        return Float.random(min: 0, max: 1, precision:2) < (Float(chance)/100)
    }

}


class SnakeHead: SnakePart {

    override init(){
        super.init()
        partType = .Head
    }

    override init!(texture: CCTexture!, rect: CGRect) {
        super.init(texture:texture, rect:rect)
        partType = .Head
    }
    
    override init!(texture: CCTexture!, rect: CGRect, rotated: Bool) {
        super.init(texture: texture, rect: rect, rotated: rotated)
        partType = .Head
    }
    
    override func moveTo(point destination: CGPoint, completion: () -> Void) {

        var vector1, vector2: CGPoint
        var turn1, turn2: MoveDirection
        
        let verticalFirst:Bool = (direction == .Left || direction == .Right)
        if verticalFirst {
            vector1 = ccp(position.x, destination.y)
            turn1 = position.y < destination.y ? MoveDirection.Down : MoveDirection.Up
            turn2 = vector1.x < destination.x ? MoveDirection.Right : MoveDirection.Left
        } else {
            vector1 = ccp(destination.x, position.y)
            turn1 = position.x < destination.x ? MoveDirection.Right : MoveDirection.Left
            turn2 = vector1.y < destination.y ? MoveDirection.Down : MoveDirection.Up
        }
        vector2 = ccp(destination.x, destination.y)

        let movement1 = ccpSub(position, vector1)
        let movement2 = ccpSub(vector1, vector2)
        
        let totalTravelDistance = movement1.magnitude() + movement2.magnitude()
        let totalDuration = Double(totalTravelDistance) / Snake.travelDistancePerSecond

        let portion1 = movement1.magnitude()/totalTravelDistance
        let portion2 = movement2.magnitude()/totalTravelDistance

        var actions = [CCAction]()

        if let turn1Action = MoveDirection.turnAction(from: direction, to: turn1){
            actions.append(turn1Action)
        }
        let move1 = CCActionMoveTo.actionWithDuration(portion1 * totalDuration, position: vector1) as! CCAction
        actions.append(move1)
        if let turn2Action = MoveDirection.turnAction(from: turn1, to: turn2){
            actions.append(turn2Action)
        }
        let move2 = CCActionMoveTo.actionWithDuration(portion2 * totalDuration, position: vector2) as! CCAction
        actions.append(move2)
        let done = CCActionCallBlock { () -> Void in
            completion()
        }
        actions.append(done)

        runAction(CCActionSequence(array: actions))
    }

}