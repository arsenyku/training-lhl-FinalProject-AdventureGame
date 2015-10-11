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
    let intervalBetweenRedDragons:CCTime = 5

    weak var gamePhysicsNode : CCPhysicsNode!

    // Sprites
    weak var hero : Hero!
    var redDragon: RedDragon!
    weak var ground1 : CCSprite!
    weak var ground2 : CCSprite!
    var grounds : [CCSprite] = []
    var crystals : [CCNode] = []
    var platforms : [CCNode] = []
    var blackDragons : [CCSprite] = []

    // Game State
    var lastPlatform : FloatingGround = FloatingGround()
    var soundOn = false
    var sinceLastRedDragon : CCTime = CCTime()
    var redDragonSpawnPoint : CGPoint = CGPointMake(100,375)
    
	// User interaction
    var tapDetector : UITapGestureRecognizer!
    weak var coordinatesLabel : CCLabelTTF!
    weak var hitPointsLabel : CCLabelTTF!
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

    	// Update items that do not need to be changed on every frame
        // e.g. text labels, non-physics bodies, anything not animated or moving
        coordinatesLabel.string = "Crystals: \(hero.crystalsCount)"
        hitPointsLabel.string = "Hit Points: \(hero.hitPoints)"
        
	}
    
    
    override func update(delta: CCTime) {
        // Update items that need to be changed as often as possible
        // e.g. physics bodies, anything animated
        
        let effectiveScrollSpeed = scrollSpeed * (hero.isJumping ? 2.5 : 1)
        
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - effectiveScrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
		hero.position = ccp(hero.position.x + effectiveScrollSpeed * CGFloat(delta), hero.position.y)
        redDragonSpawnPoint.x += (effectiveScrollSpeed * CGFloat(delta))
        
        redDragon?.flyForward(delta)
        
        // Fix black-line artifacts from looping environment
        let scale = CCDirector.sharedDirector().contentScaleFactor
        hero.position = ccp(round(hero.position.x * scale) / scale, round(hero.position.y * scale) / scale)
        gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale)
    
        loopTheGroundIfNeeded()
        
        removeAndSpawnPlatformIfNeeded()
        removeCrystalsIfNeeded()
        removeRedDragonIfNeeded(delta)
     
        spawnRedDragonIfNeeded(delta)
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, floatingGround: FloatingGround!) -> Bool {
        let distanceWhenStandingOnGround:CGFloat = 25
        
        if (hero.position.y < FloatingGround.minPlatformHeight){
            // Hero is on ground - ignore collision
            return false
            
        } else if (hero.position.y - floatingGround.position.y > distanceWhenStandingOnGround){
            // Hero is on top of platform - accept collision
            return true
            
        } else {
            // Hero is below the platform - ignore the collision
            return false
        }
        
    }
   
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, dragon: RedDragon!) -> Bool {
		
        hero.hitByEnemy(dragon)
        return false
        
    }

    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, floatingGround: FloatingGround!) {
        if (hero.isJumping) {
            hero.landJump()
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, ground: CCNode!) -> Bool {
        hero.die(withAnimation: "Lava Sink Timeline")
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, crystal: CCNode!) -> Bool {
		hero.grabCrystal()
        crystal.removeFromParent()
        crystals.removeAtIndex(crystals.indexOf(crystal)!)
        return false
    }

    func loopTheGroundIfNeeded(){
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
        
    }
    
    func removeAndSpawnPlatformIfNeeded(){
        for platform in Array(platforms.reverse()) {
            let platformWorldPosition = gamePhysicsNode.convertToWorldSpace(platform.position)
            let platformScreenPosition = convertToNodeSpace(platformWorldPosition)
            let platformScaledContentWidth = platform.contentSize.width * CGFloat(platform.scaleX)
            
            // platform moved past left side of screen?
            if platformScreenPosition.x < (-platformScaledContentWidth) {
                platform.removeFromParent()
                platforms.removeAtIndex(platforms.indexOf(platform)!)

				spawnNewPlatform()
                
                if (rollD100(successChance: 80)) {
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
    
    
    func removeRedDragonIfNeeded(deltaTime:CCTime){
        
        if redDragon != nil {
        
            let redDragonWorldPosition = gamePhysicsNode.convertToWorldSpace(redDragon.position)
            let redDragonScreenPosition = convertToNodeSpace(redDragonWorldPosition)
            
            // dragon moved off screen?
            if redDragonScreenPosition.x < (-redDragon.contentSize.width) {
                redDragon.removeFromParent()
                redDragon = nil
                sinceLastRedDragon = deltaTime
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
    
    func spawnRedDragonIfNeeded(deltaTime:CCTime){
        sinceLastRedDragon += deltaTime
        if redDragon == nil  && !hero.isJumping && rollD100(successChance: 25) {
        
            redDragonSpawnPoint.x = hero.position.x - 200
            
            redDragon = RedDragon.spawn(relativeTo:redDragonSpawnPoint, rightToLeft:rollD100())
            redDragon.zOrder = hero.zOrder + 10
            gamePhysicsNode.addChild(redDragon)
            
        }
    }
    
    // MARK: Helpers
    
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
