//
//  Snake.swift
//  AdventureGame
//
//  Created by asu on 2015-10-14.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Snake {

    private(set) internal var parts:[SnakePart] = []
    
    var head:SnakePart? {
        get{
            return self.parts.count > 0 ? self.parts[0] : nil
        }
    }
    
    func hiss(){
        
    }
    
    class func spawn(on spawnPoint:CGPoint) -> Snake {
		let snake = Snake()
		let headPart = SnakePart.spawn(.Head)
        headPart.position = ccp(spawnPoint.x - 100, spawnPoint.y)
        snake.parts.append(headPart)

        return snake
    }


}
