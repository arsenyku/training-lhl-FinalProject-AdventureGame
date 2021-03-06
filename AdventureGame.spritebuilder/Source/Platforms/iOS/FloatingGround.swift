//
//  FloatingGround.swift
//  AdventureGame
//
//  Created by asu on 2015-10-08.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class FloatingGround : CCNode {

    static let minPlatformHeight:CGFloat = 65
    static let maxPlatformHeight:CGFloat = 160
    static let platformSpacing:CGFloat = 80
    
    private(set) internal var canSpawnBlackDragon:Bool = false

    func spawnBlackDragon() -> BlackDragon? {
        var result:BlackDragon? = nil
        if canSpawnBlackDragon {
            result = BlackDragon.spawn(on: self)
        }
        return result
    }
    
    class func spawn(relativeTo reference:FloatingGround, levelEnd:Bool = false) -> FloatingGround {
        
        // create and add a new platform
        var platform:FloatingGround
        let randomGround = Int.random(min:1, max:3)
        
        switch(randomGround){
        case 1:
            platform = CCBReader.load("FloatingGroundShort") as! FloatingGround
        case 2:
            platform = CCBReader.load("FloatingGroundMedium") as! FloatingGround
        default:
            platform = CCBReader.load("FloatingGround") as! FloatingGround
            platform.canSpawnBlackDragon = true
        }

        var yOffsetMax:Int = 80
        var yOffsetMin:Int = -yOffsetMax
        
        if (levelEnd) {
            let newPlatformX = reference.position.x + reference.contentSize.width
            let newPlatformY = minPlatformHeight
            
            platform.position = ccp(newPlatformX, newPlatformY)

        } else {
            let nearTop = abs(maxPlatformHeight - reference.position.y) < 35
            let nearBottom = abs(reference.position.y - minPlatformHeight) < 35
            
            if (nearBottom) {
                yOffsetMin = 0
            } else if (nearTop) {
                yOffsetMax = 0
            }
            
            let newPlatformX = reference.position.x + reference.contentSize.width + platformSpacing
            let newPlatformY = min(maxPlatformHeight, max(minPlatformHeight, reference.position.y + CGFloat(Int.random(min:yOffsetMin, max:yOffsetMax))))
            
            platform.position = ccp(newPlatformX, newPlatformY)
        }

        return platform
    }
    
}