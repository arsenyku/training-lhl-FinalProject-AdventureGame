//
//  Int+Random.swift
//  AdventureGame
//
//  Created by asu on 2015-10-09.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

extension Int{
    static func random(min min:Int, max:Int) -> Int{
        assert(max >= min)
        return (min + Int(arc4random_uniform(UInt32(max - min + 1))))
    }

}


