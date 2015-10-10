//
//  Crystal.swift
//  AdventureGame
//
//  Created by asu on 2015-10-08.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Crystal : CCNode {

    class func spawn(relativeTo referencePoint:CGPoint) -> Crystal{
        let crystal = CCBReader.load("Crystal") as! Crystal
        crystal.position = ccp(referencePoint.x - 25, referencePoint.y + 125)
        return crystal
    }
    
}