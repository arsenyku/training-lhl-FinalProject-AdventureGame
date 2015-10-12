//
//  Hero.swift
//  AdventureGame
//
//  Created by asu on 2015-10-09.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Hero : CCSprite {
    
    let targetCrystalCount = 5
    
    private(set) internal var crystalsCount:Int = 0
    private(set) internal var hitPoints:Int = 50
    private(set) internal var isJumping = false
    
    private var currentEnemy: CCSprite!
    
    let jumpImpulse : CGFloat = 125

    var hasWon:Bool {
        get{
            return crystalsCount >= targetCrystalCount
        }
    }

    var isDead:Bool {
        get {
            return hitPoints <= 0
        }
    }
    
    func grabCrystal(){
        crystalsCount += 1
    	playSound(named: "CrystalGrab.mp3")
        
        if hasWon{
            playAnimation(named: "Standing Timeline")
        }
    }
    
    func jump(){
        if isDead || hasWon || isJumping {
            return
        }
        
		physicsBody.applyImpulse(ccp(0, jumpImpulse))
        isJumping = true
    	playSound(named:"LavaJump.mp3")
        
		playAnimation(named: "Leaping Timeline")
        
    }
    
    func landJump(){
        isJumping = false
        playAnimation(named: "Running Timeline")
    }
    
    func hitByEnemy(enemy:CCSprite){
        if !hasWon && !isDead && currentEnemy != enemy{
            currentEnemy = enemy
	        hitPoints -= 1
            
            if enemy.isKindOfClass(RedDragon) {
                playAnimation(named: "Damage Timeline")
                playSound(named: "RedDragonImpact.wav")
                
            } else if enemy.isKindOfClass(BlackDragon){
                playAnimation(named: "Running Damage Timeline")
                playSound(named: "BlackDragonImpact.mp3")
                
            } else {
                playAnimation(named: "Running Damage Timeline")
            }
            
		}
        
        if hitPoints < 1 {
            die(withAnimation: "Painful death")
        }
    }
    
    func hitByEnvironment(environment:CCNode){
       
    }
    
    
    
    func die(withAnimation animation:String){
        isJumping = false
        hitPoints = 50
//        isDead = true
//        animationManager.runAnimationsForSequenceNamed("Standing Timeline")
    }
    
    func exitStage() {
        print ("exit stage")
        playAnimation(named: "Running Timeline")
        physicsBody.applyImpulse(ccp(50, 0))
    }
    
    func playSound(named soundName:String){
        OALSimpleAudio.sharedInstance().playEffect(soundName)
    }
    
    func playAnimation(named animation:String){
        animationManager.runAnimationsForSequenceNamed(animation)
    }
}