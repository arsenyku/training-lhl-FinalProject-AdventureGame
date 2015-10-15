//
//  CGPoint+VectorMagnitude.swift
//  AdventureGame
//
//  Created by asu on 2015-10-14.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

extension CGPoint {
    func magnitude() -> Double {
	    let deltaXSquared = pow(self.x, 2)
    	let deltaYSquared = pow(self.y, 2)
    	let magnitude = sqrt( deltaXSquared + deltaYSquared )
        return Double(magnitude)
    }
}