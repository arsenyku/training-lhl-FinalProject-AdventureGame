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
    static let travelDistancePerSecond:Double = 180
    static let partOffset:CGFloat = 32

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
//            return prey.position == head?.position
            return tileMap.sameTile(pointA: head!.position, pointB: prey.position)
        

        }
    }

    func moveForward(deltaTime:CCTime){
        sinceLastMove += deltaTime

        guard caughtPrey == false && sinceLastMove > 0.1 else{
            return
        }

        for part in parts {
            part.moveToNextTile()
        }
        sinceLastMove = 0

    }
    
    
    func chase(){
        if isChasing || caughtPrey {
            return
        }
        

        if let nextPoint = chasePoints.first {
            
            isChasing = true

            for part in parts {
            
                if let part = part as? SnakeHead {
                    part.moveTo(point: nextPoint) { () -> Void in
                        self.isChasing = false
                        self.finishChase()
                    }
                } else {
        
                    
                }
            }
            
        } else {
            isChasing = false
        }
    }
    
    func addChasePoint(point: CGPoint) {

		chasePoints.append(point)
    }
    
    private func finishChase(){
        stopAllActions()
        if (self.chasePoints.count > 0)	{
            self.chasePoints.removeFirst()
        }
        
        if self.chasePoints.count < 1 && !caughtPrey {
            self.addChasePoint(self.prey.position)
        }

    }

    
    private func stopAllActions(){
        for snakePart in parts{
            snakePart.stopAllActions()
        }
    }
    
    
    class func spawn(prey prey:HeroStage2) -> Snake {
		let snake = Snake()
        snake.prey = prey
        
        let spawnPoint = snake.tileMap.tileAt(point: ccp(0,0)).origin
//        var spawnPoint = ccp(hero.position.x, hero.position.y)
//        spawnPoint.x = spawnPoint.x - preyDistance
//        spawnPoint.y = spawnPoint.y + 0
        
        let headPart = SnakePart.spawn(.Head)
        headPart.position = spawnPoint
        headPart.snake = snake
        snake.parts.append(headPart)

        snake.tileMap.tileSize = snake.head!.contentSize
        
        var last = snake.parts.last!

        for _ in 1...3 {
            let bodyPart = SnakePart.spawn(.Body)
            bodyPart.position = snake.tileMap.nextTile(forSprite: last, inDirection: .Left)!.origin
            bodyPart.frontPart = last
            bodyPart.snake = snake
            
            snake.parts.append(bodyPart)
            last = snake.parts.last!
        }
        
        let tailPart = SnakePart.spawn(.Tail)
        tailPart.position = snake.tileMap.nextTile(forSprite: last, inDirection: .Left)!.origin
		tailPart.frontPart = last
        tailPart.snake = snake
        snake.parts.append(tailPart)
        
        print("head at  \(headPart.position)   size=\(headPart.contentSize)")
        print("tail at  \(tailPart.position)   size=\(tailPart.contentSize)")
        return snake
    }


}
