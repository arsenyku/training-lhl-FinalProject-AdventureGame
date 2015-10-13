//
//  Stage2Scene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-13.
//  Copyright © 2015 Apportable. All rights reserved.
//

class Stage2Scene: CCNode, CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate {

    weak var gamePhysicsNode : CCPhysicsNode!
	var tapDetector : UITapGestureRecognizer!
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        gamePhysicsNode.collisionDelegate = self
        
        tapDetector = UITapGestureRecognizer(target: self, action: Selector("tapDetected:"))
        tapDetector.numberOfTapsRequired = 1
        tapDetector.delegate = self
        
                
    }


}