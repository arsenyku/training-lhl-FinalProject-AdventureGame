//
//  BombExplosion.swift
//  AdventureGame
//
//  Created by asu on 2015-10-26.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class BombExplosion : CCParticleSystem {
    
    class func spawn(on snakePart:SnakePart, duration:CCTime) -> BombExplosion {
        let boom = CCBReader.load("BombExplosion") as! BombExplosion
        let boomX = snakePart.position.x // + (snakePart.contentSize.width/2)
        let boomY = snakePart.position.y // + (snakePart.contentSize.height/2)

        boom.positionType.corner = .TopLeft
        boom.position = ccp(boomX, boomY)

        boom.zOrder = snakePart.zOrder + 1
        boom.duration = 1
        boom.scale = 0.5
        boom.autoRemoveOnFinish = true
        
        return boom
    }
    
}