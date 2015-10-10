//
//  MainScene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-07.
//  Copyright © 2015 Apportable. All rights reserved.
//
import UIKit

class Stage1Scene: CCNode, CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate {

    let scrollSpeed : CGFloat = 70

    weak var gamePhysicsNode : CCPhysicsNode!

    // Sprites
    weak var hero : Hero!
    weak var ground1 : CCSprite!
    weak var ground2 : CCSprite!
    var grounds = [CCSprite]()
    var crystals : [CCNode] = []
    var platforms : [CCNode] = []

    // Game State
    var lastPlatform : FloatingGround = FloatingGround()
    var soundOn = false
    
    
	// User interaction
    var tapDetector : UITapGestureRecognizer!
    weak var coordinatesLabel : CCLabelTTF!
    weak var soundToggleButton : CCButton!
    
    // MARK: Lifecycle
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
		
        gamePhysicsNode.collisionDelegate = self
        
        grounds.append(ground1)
        grounds.append(ground2)

        tapDetector = UITapGestureRecognizer(target: self, action: Selector("tapDetected:"))
        tapDetector.numberOfTapsRequired = 1
        tapDetector.delegate = self
        
        soundToggleButton.setTarget(self, selector: Selector("soundToggle:"))
        
        CCDirector.sharedDirector().view.addGestureRecognizer(tapDetector)

        lastPlatform.position = CGPointMake(hero.position.x - FloatingGround.platformSpacing, FloatingGround.minPlatformHeight)

        for _ in 1...5{
            spawnNewPlatform()
        }
        
        hero.zOrder = 100
        
        let audio = OALSimpleAudio.sharedInstance()
        audio.muted = true
        audio.bgVolume = 0.25
        audio.playBg("LavaTheme.mp3", loop: true)

    }

    // MARK: User Interaction
    
    func tapDetected(sender:UITapGestureRecognizer){
        if (hero.isJumping == false){
            hero.jump()
            playJumpSound()
        }
    }
    

    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {

        let touchLocation = CCDirector.sharedDirector().convertToGL(touch.locationInView(touch.view))
        let responder = CCDirector.sharedDirector().responderManager
        let node = responder.nodeAtPoint(touchLocation)
        
        if node.isKindOfClass(CCButton) {
            return false
        }
        
        return true;
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
    


    // MARK: Game logic
    override func fixedUpdate(delta: CCTime) {

    
        coordinatesLabel.string = "Crystals: \(hero.crystalsCount)"
        
	}
    
    
    override func update(delta: CCTime) {
        let effectiveScrollSpeed = scrollSpeed * (hero.isJumping ? 2.5 : 1)
        
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - effectiveScrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
		hero.position = ccp(hero.position.x + effectiveScrollSpeed * CGFloat(delta), hero.position.y)
        
        // Fix black-line artifacts from looping environment
        let scale = CCDirector.sharedDirector().contentScaleFactor
        hero.position = ccp(round(hero.position.x * scale) / scale, round(hero.position.y * scale) / scale)
        gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale)
    
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in grounds {
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            let groundScaledContentWidth = ground.contentSize.width * CGFloat(ground.scaleX)
            let correctionForPixelBoundary = CGFloat(-1) // removes space between ground objects due to width scaling
            if groundScreenPosition.x <= (-groundScaledContentWidth) {
                ground.position = ccp((ground.position.x + groundScaledContentWidth * 2) + correctionForPixelBoundary, ground.position.y)
            }
        }
    
        
        removePlatformIfNeeded()
        removeCrystalsIfNeeded()
        
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, floatingGround: CCNode!) -> Bool {
        let distanceWhenStandingOnGround:CGFloat = 40
        
        if (hero.position.y - floatingGround.position.y > distanceWhenStandingOnGround){
            // Hero is on top - accept collision
            return true
        } else {
            // Hero is below the platform - ignore the collision
            return false
        }
        
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, floatingGround: CCNode!) {
        if (hero.isJumping) {
            hero.landJump()
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, ground: CCNode!) -> Bool {
        hero.die()
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, crystal: CCNode!) -> Bool {
		hero.crystalsCount += 1
        crystal.removeFromParent()
        crystals.removeAtIndex(crystals.indexOf(crystal)!)
        playCrystalGrabSound()
        return false
    }

    func removePlatformIfNeeded(){
        for platform in Array(platforms.reverse()) {
            let platformWorldPosition = gamePhysicsNode.convertToWorldSpace(platform.position)
            let platformScreenPosition = convertToNodeSpace(platformWorldPosition)
            let platformScaledContentWidth = platform.contentSize.width * CGFloat(platform.scaleX)
            
            // platform moved past left side of screen?
            if platformScreenPosition.x < (-platformScaledContentWidth) {
                platform.removeFromParent()
                platforms.removeAtIndex(platforms.indexOf(platform)!)

				spawnNewPlatform()
                
                if (Int.random(min: 1, max: 100) < 80) {
                    spawnNewCrystal()
                }
            }
        }
        
    }
    
    func removeCrystalsIfNeeded(){
        
        for crystal in Array(crystals.reverse()) {
            let crystalWorldPosition = gamePhysicsNode.convertToWorldSpace(crystal.position)
            let crystalScreenPosition = convertToNodeSpace(crystalWorldPosition)
            
            // crystal moved past left side of screen?
            if crystalScreenPosition.x < (-crystal.contentSize.width) {
                crystal.removeFromParent()
                crystals.removeAtIndex(crystals.indexOf(crystal)!)
            }
        }
    
    }
    
    func spawnNewPlatform(){
        let platform = FloatingGround.spawn(relativeTo: lastPlatform)
        gamePhysicsNode.addChild(platform)
        platforms.append(platform)
        
        lastPlatform = platform
    
    }
    
    func spawnNewCrystal (){
        let crystal = Crystal.spawn(relativeTo: lastPlatform.position)

        gamePhysicsNode.addChild(crystal)
        crystals.append(crystal)

    }
    
    // MARK: Helpers
    
    func playSound() {
		OALSimpleAudio.sharedInstance().muted = false
    }

    func stopSound() {
    	OALSimpleAudio.sharedInstance().muted = true
    
    }

    func playJumpSound(){
        OALSimpleAudio.sharedInstance().playEffect("LavaJump.mp3")
    }
    
    func playCrystalGrabSound(){
        OALSimpleAudio.sharedInstance().playEffect("CrystalGrab.mp3")
        
    }
    
       
}
