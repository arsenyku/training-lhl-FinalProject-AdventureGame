//
//  RedDragon.swift
//  AdventureGame
//
//  Created by asu on 2015-10-10.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class RedDragon : CCSprite {

    private(set) internal var flightPath:[CGPoint] = []
    var flightStep:Int = 0
    var sinceLastFlightStep:CCTime = 0
    var flightStepDelay:CCTime = 0.14
    var rightToLeft:Bool = true
    
    func calculateFlightPath(startingAt startPoint:CGPoint){
        flightPath = ellipsePath(from: startPoint)
    }
    
    func reverseFlightPath(){
        flightPath = flightPath.reverse()
        rightToLeft = !rightToLeft
    }
    
    func flyForward(deltaTime:CCTime){
        sinceLastFlightStep += deltaTime
        if flightStep+1 < flightPath.count && sinceLastFlightStep > flightStepDelay {
            flightStep += 1
            position = flightPath[flightStep]
            sinceLastFlightStep = 0
        }
        if (flightStep+1 == flightPath.count && rightToLeft == false && flightPath.count > 0)
        {
            position = flightPath.first!
        }
    }
    
    private func ellipsePath(from startPoint:CGPoint) -> [CGPoint]{
        // M_PI/6 = 0.52359877559
        
        let view = CCDirector.sharedDirector().view
        let dragonPath = UIBezierPath.pointsArrayForOvalInRect(view.frame , startAngle: CGFloat(0.4), endAngle: CGFloat(2.75), angleStep:CGFloat(M_PI/20))
        
        if ( dragonPath == nil || dragonPath.count < 1 ) {
            return []
        }
        
        let lastFlightPoint = (dragonPath.last as! NSValue).CGPointValue()
        let yAdjustment = fabs(startPoint.y - lastFlightPoint.y)
        let xAdjustment = fabs(startPoint.x - lastFlightPoint.x)

        return dragonPath.map{ pointAsValue -> CGPoint in
            var point = (pointAsValue as! NSValue).CGPointValue()
            point.x += xAdjustment
			point.y += yAdjustment
            
            return point
        }
        
    }
    
    class func spawn(relativeTo referencePoint:CGPoint, rightToLeft:Bool = true) -> RedDragon {
        let dragon = CCBReader.load("RedDragon") as! RedDragon
        dragon.calculateFlightPath(startingAt: referencePoint)
        
        if (rightToLeft == false){
            dragon.reverseFlightPath()
        }
        
        dragon.position = dragon.flightPath.first!
        dragon.flipX = rightToLeft
        
        return dragon
    }

}