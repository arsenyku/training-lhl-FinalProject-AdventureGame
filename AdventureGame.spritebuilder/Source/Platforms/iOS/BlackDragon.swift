//
//  BlackDragon.swift
//  AdventureGame
//
//  Created by asu on 2015-10-11.
//  Copyright © 2015 Apportable. All rights reserved.
//


import Foundation

class BlackDragon : CCSprite {
        
    class func spawn(on platform:FloatingGround) -> BlackDragon {
		let dragon = CCBReader.load("BlackDragon") as! BlackDragon
        let dragonX = platform.position.x + (platform.contentSize.width/2)
        let dragonY = platform.position.y + platform.contentSize.height + (dragon.contentSize.height/2) - 5
        dragon.position = ccp(dragonX, dragonY)
        return dragon
    }
    
}