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
            self.rotation = forward.angle
            position = next.origin
        }
    }

    
}
