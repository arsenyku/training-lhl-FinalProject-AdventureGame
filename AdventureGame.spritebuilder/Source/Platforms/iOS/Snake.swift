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

    private(set) internal var parts:[SnakePart] = []
    private(set) internal var chasePoints:[CGPoint] = []
    private(set) internal var isChasing:Bool = false
    
    private(set) internal var health = Snake.maxHealth
    
    private(set) internal var prey: HeroStage2!
    
    var head:SnakePart? {
        get{
            return self.parts.count > 0 ? self.parts[0] : nil
        }
    }
    
    var caughtPrey:Bool {
        get {
            return prey.position == head?.position
        }
    }

    func chase(){
        if isChasing || caughtPrey {
            return
        }
        

        if let nextPoint = chasePoints.first {
            
            isChasing = true

            head?.moveTo(point: nextPoint) { () -> Void in
                self.isChasing = false
                self.finishChase()
            }
        } else {
            isChasing = false
        }
    }
    
    func addChasePoint(point: CGPoint) {

		chasePoints.append(point)
    }
    
    private func finishChase(){
        self.head?.stopAllActions()
        if (self.chasePoints.count > 0)	{
            self.chasePoints.removeFirst()
        }
        
        if self.chasePoints.count < 1 && !caughtPrey {
            self.addChasePoint(self.prey.position)
        }

    }
    
    
    class func spawn(relativeTo hero:HeroStage2) -> Snake {
		let snake = Snake()
        snake.prey = hero

        let offset:CGFloat = 150
//        let randomPointMarker = Int.random(min:1, max:8)
//        let randomPointMarker = 1
        var spawnPoint = ccp(hero.position.x, hero.position.y)
        
//        switch(randomPointMarker){
//        case 1:
//            spawnPoint.x -= offset
//        case 2:
//            spawnPoint.y += offset
//        case 3:
//            spawnPoint.y -= offset
//        case 4:
//            spawnPoint.x -= offset
//            spawnPoint.y += offset
//        case 5:
//            spawnPoint.x += offset
//            spawnPoint.y += offset
//        case 6:
//            spawnPoint.x += offset
//            spawnPoint.y -= offset
//        case 7:
//            spawnPoint.x -= offset
//            spawnPoint.y -= offset
//        default:
//            spawnPoint.x += offset
//        }
        
        
        spawnPoint.x = spawnPoint.x - offset
        spawnPoint.y = spawnPoint.y + 0
        
        let headPart = SnakePart.spawn(.Head)
        headPart.position = spawnPoint
        snake.parts.append(headPart)

        return snake
    }


}
