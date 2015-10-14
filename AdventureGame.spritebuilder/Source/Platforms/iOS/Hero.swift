//
//  Hero.swift
//  AdventureGame
//
//  Created by asu on 2015-10-09.
//  Copyright © 2015 Apportable. All rights reserved.
//

import Foundation

class Hero : CCSprite {
    
    let targetCrystalCount = 10
	static let initialHitPoints = 10
    let jumpImpulse : CGFloat = 125
    

    // Stage 1 properties
    private(set) internal var crystalsCount:Int = 0
    private(set) internal var hitPoints:Int = Hero.initialHitPoints
    private(set) internal var isJumping = false
    private var currentEnemy: CCSprite!
    
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
            physicsBody.velocity = CGPointMake(0,0)
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
            die(withAnimation: "Death Timeline")
        }
    }
    
    func hitByEnvironment(environment:CCNode){
        if environment.isKindOfClass(SafeGround){
            physicsBody.elasticity = 0
        }
    }
    
    
    
    func die(withAnimation animation:String){
        isJumping = false
        hitPoints = 0
        playSound(named: "DeathScream.mp3")
        playAnimation(named: animation)
    }
    
    func exitStage() {
        print("exit stage")
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