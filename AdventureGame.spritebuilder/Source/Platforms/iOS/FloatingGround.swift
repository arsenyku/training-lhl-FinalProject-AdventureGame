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
    static let maxPlatformHeight:CGFloat = 150

    static let platformSpacing:CGFloat = 275

    class func spawn(stageInit stageInit:Bool = false, relativeTo referencePoint:CGPoint) -> FloatingGround {
        
        // create and add a new platform
        let platform = CCBReader.load("FloatingGround") as! FloatingGround
        
        let yOffsetMax:Int = 80
        let yOffsetMin:Int = stageInit ? 0 : -yOffsetMax
        
        let newPlatformX = referencePoint.x + platformSpacing
        let newPlatformY = min(maxPlatformHeight, max(minPlatformHeight, referencePoint.y + CGFloat(Int.random(min:yOffsetMin, max:yOffsetMax))))
        
        platform.position = ccp(newPlatformX, newPlatformY)

        print("platform spawn at \(platform.position)")
        
        return platform
    }
    
}