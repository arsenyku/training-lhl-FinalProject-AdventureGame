//
//  Float+Random.swift
//  AdventureGame
//
//  Created by asu on 2015-10-09.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

extension Float{
    static
        func randomFloat(min min:Float, max:Float, precision:UInt32) -> Float{
            let precisionFactor = pow(Float(10),Float(precision))
            let adjustedMin = Int(min * precisionFactor)
            let adjustedMax = Int(max * precisionFactor)
            
            let result = Float(Int.random(min:adjustedMin, max:adjustedMax)) / precisionFactor
            return result
    }

}