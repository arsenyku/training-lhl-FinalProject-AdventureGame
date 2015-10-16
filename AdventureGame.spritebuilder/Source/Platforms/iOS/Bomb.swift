//
//  Bomb.swift
//  AdventureGame
//
//  Created by asu on 2015-10-16.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Bomb: CCSprite {
    class func spawn(on point:CGPoint) -> Bomb{
        let bomb = CCBReader.load("Bomb") as! Bomb
        bomb.positionType.corner = .TopLeft
        bomb.scale = 0.5
        bomb.zOrder = 25
        bomb.position = point
        return bomb
    }
}