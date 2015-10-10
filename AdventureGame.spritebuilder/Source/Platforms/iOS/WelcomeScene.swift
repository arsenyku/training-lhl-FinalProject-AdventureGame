//
//  WelcomeScene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-09.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class WelcomeScene: CCNode {

    
    func didLoadFromCCB(){
        OALSimpleAudio.sharedInstance().playBg("WelcomeTheme.mp3", loop: true)

    }
    
    func newGame(sender: CCButton?) {
      
        OALSimpleAudio.sharedInstance().stopBg()
        let gameplayScene = CCBReader.loadAsScene("Stage1Scene")
        CCDirector.sharedDirector().replaceScene(gameplayScene)
        
    }


    func reloadGame(sender: CCButton?) {

    }
    
    func optionsScreen(sender: CCButton?) {
    }
    
}