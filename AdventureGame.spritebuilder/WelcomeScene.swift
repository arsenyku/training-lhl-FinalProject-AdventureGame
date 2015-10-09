//
//  WelcomeScene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-09.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class WelcomeScene: CCNode {

    
    func newGame(sender: CCButton?) {
      
        let gameplayScene = CCBReader.loadAsScene("Stage1Scene")
        CCDirector.sharedDirector().replaceScene(gameplayScene)
        
    }

    
}