//
//  Snake.swift
//  AdventureGame
//
//  Created by asu on 2015-10-14.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Snake {

    static let maxHealth:Int = 100
    static let partOffset:CGFloat = 32
    static let minMoveInterval:CCTime = 0.1
    static let defaultBodyLength = 30
    
    static let normalBodyImage = "Animation/snakebody.png"
    static let bentBodyImage = "Animation/snakebend.png"
    
    let tileMap: SnakeTileMap = SnakeTileMap()

    private(set) internal var parts:[SnakePart] = []
    private(set) internal var chasePoints:[CGPoint] = []
    private(set) internal var isChasing:Bool = false
    private(set) internal var sinceLastMove:CCTime = 0

    private(set) internal var health = Snake.maxHealth
    
    private(set) internal var prey: HeroStage2!
    
    var head:SnakePart? {
        get{
            return self.parts.count > 0 ? self.parts[0] : nil
        }
    }
    
    var caughtPrey:Bool {
        get {
            return tileMap.sameTile(pointA: head!.position, pointB: prey.position)
        }
    }

    func moveForward(deltaTime:CCTime){
        sinceLastMove += deltaTime

        guard caughtPrey == false && sinceLastMove > Snake.minMoveInterval else{
            return
        }

        for part in parts {
            part.moveToNextTile()
        }

        sinceLastMove = 0

    }
    
    
    
    private func stopAllActions(){
        for snakePart in parts{
            snakePart.stopAllActions()
        }
    }
    
    
    class func spawn(prey prey:HeroStage2) -> Snake {
		let snake = Snake()
        snake.prey = prey
        
        var zOrder = prey.zOrder + 100
        
        let spawnPoint = snake.tileMap.tileAt(point: ccp(0,0)).origin

        let headPart = SnakePart.spawn(.Head)
        headPart.position = spawnPoint
        headPart.snake = snake
        headPart.zOrder = zOrder
        snake.parts.append(headPart)

        snake.tileMap.tileSize = snake.head!.contentSize
        
        var last = snake.parts.last!

        for _ in 1...Snake.defaultBodyLength {
            zOrder -= 1
            let bodyPart = SnakePart.spawn(.Body)
            bodyPart.position = snake.tileMap.nextTile(forSprite: last, inDirection: .Left)!.origin
            bodyPart.frontPart = last
            bodyPart.snake = snake
            bodyPart.zOrder = zOrder
            
            snake.parts.append(bodyPart)
            last = snake.parts.last!
        }
        
        let tailPart = SnakePart.spawn(.Tail)
        tailPart.position = snake.tileMap.nextTile(forSprite: last, inDirection: .Left)!.origin
		tailPart.frontPart = last
        tailPart.snake = snake
        tailPart.zOrder = zOrder - 1
        snake.parts.append(tailPart)
        
        return snake
    }


}
