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

    class func spawn(relativeTo referencePoint:CGPoint) -> FloatingGround {
        
        // create and add a new platform
        let platform = CCBReader.load("FloatingGround") as! FloatingGround
        
        var yOffsetMax:Int = 80
        var yOffsetMin:Int = -yOffsetMax
        
        let nearTop = abs(maxPlatformHeight - referencePoint.y) < 35
        let nearBottom = abs(referencePoint.y - minPlatformHeight) < 35
        
        if (nearBottom) {
            yOffsetMin = 0
        } else if (nearTop) {
            yOffsetMax = 0
        }
        
        let newPlatformX = referencePoint.x + platformSpacing
        let newPlatformY = min(maxPlatformHeight, max(minPlatformHeight, referencePoint.y + CGFloat(Int.random(min:yOffsetMin, max:yOffsetMax))))
        
        platform.position = ccp(newPlatformX, newPlatformY)

        print("platform spawn at \(platform.position)")
        
        return platform
    }
    
}