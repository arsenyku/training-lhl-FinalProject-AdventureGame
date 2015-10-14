//
//  SnakePart.swift
//  AdventureGame
//
//  Created by asu on 2015-10-14.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

enum PartType {
    case Head
    case Body
    case Tail
}


class SnakePart : CCSprite {

    var partType: PartType = .Body
    
    class func spawn(type type:PartType = .Body) -> SnakePart{
        var partName:String
        switch (type) {
        case .Head:
	        partName = "SnakeHead"
        case .Tail:
            partName = "SnakeTail"
        default:
            partName = "SnakeBody"
        }
        
        let snakePart =  CCBReader.load(partName) as! SnakePart
    	snakePart.scale = 1.5
        
        return snakePart
    }

}
