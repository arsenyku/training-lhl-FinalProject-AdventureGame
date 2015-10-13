//
//  SafeGround.swift
//  AdventureGame
//
//  Created by asu on 2015-10-12.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class SafeGround : CCNode {

    var referencePoint: CGPoint!
    
    var fullyRaised:Bool{
        return (position.y >= referencePoint.y + (contentSize.height/2) + 5)
    }
    
    func raise(){
        if !fullyRaised {
            position.y += 5
	    }
    }
    
    class func spawn(relativeTo referencePoint:CGPoint) -> SafeGround{
        let result = CCBReader.load("SafeGround") as! SafeGround
        result.referencePoint = referencePoint
        result.position = ccp(referencePoint.x, referencePoint.y - (result.contentSize.height/4))

        return result
    }
}