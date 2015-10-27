//
//  AdventureScene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-16.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class AdventureScene: CCNode, CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate {
   
    var replayScene:String!
    var nextScene:String!
    
    weak var gamePhysicsNode : CCPhysicsNode!

    var soundOn = false
    var dirgePlayed = false
    var sinceHeroDeath:CCTime = 0

    weak var soundToggleButton : CCButton!
    weak var endStageUI: CCNode!
    weak var gameOverUI: CCNode!
    weak var nextStageButton: CCButton!
    weak var replayStageButton: CCButton!
    weak var replayAfterDeathButton: CCButton!
    weak var nextStageAfterDeathButton: CCButton!

    var tapDetector : UITapGestureRecognizer!

    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        gamePhysicsNode.collisionDelegate = self
  
        tapDetector = UITapGestureRecognizer(target: self, action: Selector("tapDetected:"))
        tapDetector.numberOfTapsRequired = 1
        tapDetector.delegate = self
        CCDirector.sharedDirector().view.addGestureRecognizer(tapDetector)
        
        soundToggleButton.setTarget(self, selector: Selector("soundToggle:"))
        
        let audio = OALSimpleAudio.sharedInstance()
        audio.stopEverything()
        audio.muted = true
        audio.bgVolume = 0.25
        
    }

    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        let touchLocation = CCDirector.sharedDirector().convertToGL(touch.locationInView(touch.view))
        let responder = CCDirector.sharedDirector().responderManager
        let node = responder.nodeAtPoint(touchLocation)
        
        if let node = node where node.isKindOfClass(CCButton) {
            return false
        }
        
        return true;
    }
    

    func showEndStage(){
        if heroIsDead(){
            OALSimpleAudio.sharedInstance().stopBg()
            gameOverUI.visible = true
            nextStageAfterDeathButton.state = .Normal
            nextStageAfterDeathButton.label.opacity = 0.25
        } else {
            endStageUI.visible = true
            nextStageButton.state = .Normal
            nextStageButton.label.opacity = 1.0
        }
    }

    
    func soundToggle(sender: AnyObject?) {
        if let toggleButton = sender as? CCButton {
            
            soundOn = !soundOn
            toggleButton.selected = soundOn
            
            if (soundOn){
                playSound()
            }
            else {
                stopSound()
            }
            
        }
    }
    
    func replayStage(sender: AnyObject?) {
        OALSimpleAudio.sharedInstance().stopBg()
        let gameplayScene = CCBReader.loadAsScene(replayScene)
        CCDirector.sharedDirector().replaceScene(gameplayScene)
    }
    
    func nextStage(sender: AnyObject?) {
        OALSimpleAudio.sharedInstance().stopBg()
        let gameplayScene = CCBReader.loadAsScene(nextScene)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: CCTransition(revealWithDirection: .Left, duration: 1.5))
    }

    // MARK: Helpers
    
    func heroIsDead() -> Bool{
        return false
    }
    
    func playDirge(){
        dirgePlayed = true
        OALSimpleAudio.sharedInstance().playBg("DeathTheme.mp3")
    }
    
    func playSound() {
        OALSimpleAudio.sharedInstance().muted = false
    }
    
    func stopSound() {
        OALSimpleAudio.sharedInstance().muted = true
        
    }
    
    func rollD100(successChance chance:Int = 50) -> Bool {
        return Float.random(min: 0, max: 1, precision:2) < (Float(chance)/100)
    }
    
    func rollDie(numberOfSides sides:UInt = 6) -> Int {
        return Int.random(min: 1, max: Int(sides))
    }
    

}

