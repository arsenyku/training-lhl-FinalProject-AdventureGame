//
//  SnakeHead.swift
//  AdventureGame
//
//  Created by asu on 2015-10-15.
//  Copyright © 2015 Apportable. All rights reserved.
//

class SnakeHead: SnakePart {
    
    var targetTile:CGRect?
    
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
    
    override func moveToNextTile() {

        let currentTile = snake.tileMap.tileAt(sprite:self)
        
        if (targetTile == nil || targetTile == currentTile){
            targetTile = snake.tileMap.tileAt(sprite:snake.prey)
        }
        
        forward = snake.tileMap.direction(from: position, to: targetTile!.origin)
        if let next = snake.tileMap.nextTile(forSprite: self, inDirection: forward){
	        position = next.origin
        }
        
    }
    
    func moveTo(point destination: CGPoint, completion: () -> Void) {
        
//        var vector1, vector2: CGPoint
//        var turn1, turn2: MoveDirection
//        
//        let verticalFirst:Bool = (direction == .Left || direction == .Right)
//        if verticalFirst {
//            vector1 = ccp(position.x, destination.y)
//            turn1 = position.y < destination.y ? MoveDirection.Down : MoveDirection.Up
//            turn2 = vector1.x < destination.x ? MoveDirection.Right : MoveDirection.Left
//        } else {
//            vector1 = ccp(destination.x, position.y)
//            turn1 = position.x < destination.x ? MoveDirection.Right : MoveDirection.Left
//            turn2 = vector1.y < destination.y ? MoveDirection.Down : MoveDirection.Up
//        }
//        vector2 = ccp(destination.x, destination.y)
//        
//        let movement1 = ccpSub(position, vector1)
//        let movement2 = ccpSub(vector1, vector2)
//        
//        let totalTravelDistance = movement1.magnitude() + movement2.magnitude()
//        let totalDuration = Double(totalTravelDistance) / Snake.travelDistancePerSecond
//        
//        let portion1 = movement1.magnitude()/totalTravelDistance
//        let portion2 = movement2.magnitude()/totalTravelDistance
//        
//        var actions = [CCAction]()
//        
//        if let turn1Action = MoveDirection.turnAction(from: direction, to: turn1){
//            actions.append(turn1Action)
//        }
//        let move1 = CCActionMoveTo.actionWithDuration(portion1 * totalDuration, position: vector1) as! CCAction
//        actions.append(move1)
//
//        if let turn2Action = MoveDirection.turnAction(from: turn1, to: turn2){
//            actions.append(turn2Action)
//        }
//        let move2 = CCActionMoveTo.actionWithDuration(portion2 * totalDuration, position: vector2) as! CCAction
//        actions.append(move2)
//        let done = CCActionCallBlock { () -> Void in
//            completion()
//        }
//        actions.append(done)
//        
////        snake.moveBody()
//        runAction(CCActionSequence(array: actions))
    }
    
}
