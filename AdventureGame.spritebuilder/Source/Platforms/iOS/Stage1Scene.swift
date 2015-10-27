//
//  MainScene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-07.
//  Copyright © 2015 Apportable. All rights reserved.
//
import UIKit

class Stage1Scene: AdventureScene {

    let scrollSpeed : CGFloat = 70
    let intervalBetweenRedDragons:CCTime = 5
    let distanceWhenStandingOnPlatform:CGFloat = 25

    // Sprites
    weak var hero : Hero!
    var redDragon: RedDragon!
    weak var ground1 : CCSprite!
    weak var ground2 : CCSprite!
    weak var safeGround1 : SafeGround!
    weak var safeGround2 : SafeGround!
    var grounds : [CCSprite] = []
    var crystals : [CCNode] = []
    var platforms : [CCNode] = []
    var blackDragons : [CCSprite] = []

    // Game State
    var lastPlatform : FloatingGround = FloatingGround()
    var sinceLastRedDragon : CCTime = CCTime()
    var redDragonSpawnPoint : CGPoint = CGPointMake(100,375)
    var stageExitTriggered: Bool = false
    
	// User interaction
    weak var coordinatesLabel : CCLabelTTF!
    weak var hitPointsLabel : CCLabelTTF!
    
    // Computed properties
    var stageEnded:Bool {
        get {
            return heroIsDead() || (hero.hasWon && heroExited)
        }
    }
    
    var heroExited:Bool {
        get{
			let heroScreenPosition = screenPositionForNode(hero)
            return heroScreenPosition.x > boundingBox().width + hero.contentSize.width
        }
    }
    
    override func heroIsDead() -> Bool {
        return hero.isDead
    }
    
    // MARK: Lifecycle
    
    override func didLoadFromCCB() {

        super.didLoadFromCCB()
        
        replayScene = "Stage1Scene"
        nextScene = "Stage2Scene"
        
        grounds.append(ground1)
        grounds.append(ground2)

        lastPlatform.position = CGPointMake(hero.position.x - FloatingGround.platformSpacing, FloatingGround.minPlatformHeight)

        for _ in 1...4{
            spawnNewPlatform()
        }
        
        hero.zOrder = 100
        hero.preStart()
     
        OALSimpleAudio.sharedInstance().playBg("LavaTheme.mp3", loop: true)

    }

    // MARK: User Interaction
    
    func tapDetected(sender:UITapGestureRecognizer){
		hero.jump()
    }
    

    
   
	// MARK: Collision checks
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, floatingGround: FloatingGround!) -> Bool {
        
        if (hero.hasWon) {
            return false
            
        } else if (hero.position.y < FloatingGround.minPlatformHeight){
            // Hero is on ground - ignore collision
            return false
            
        } else if (hero.position.y - floatingGround.position.y > distanceWhenStandingOnPlatform){
            // Hero is on top of platform - accept collision
            return true
            
        } else {
            // Hero is below the platform - ignore the collision
            return false
        }
        
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, floatingGround: FloatingGround!) {
        if (hero.isJumping) {
            hero.landJump()
        }
    }
    

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, dragon: RedDragon!) -> Bool {
        hero.hitByEnemy(dragon)
        return false
        
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, blackDragon: BlackDragon!) -> Bool {
        hero.hitByEnemy(blackDragon)
        return false
        
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, ground: CCNode!) -> Bool {
        if (hero.hasWon) {
        	return false
        } else {
	        hero.die(withAnimation: "Death Timeline")
    	    return true
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, safeGround: CCNode!) -> Bool {

        print("safe")
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, crystal: CCNode!) -> Bool {
        hero.grabCrystal()
        crystal.removeFromParent()
        crystals.removeAtIndex(crystals.indexOf(crystal)!)
        
        if hero.hasWon {
            gamePhysicsNode.gravity.y = -500
        }
        return false
    }
    

    
    // MARK: Update logic
    
    override func fixedUpdate(delta: CCTime) {

    	// Update items that do not need to be changed on every frame
        // e.g. text labels, non-physics bodies, anything not animated or moving
        coordinatesLabel.string = "Crystals: \(hero.crystalsCount) / \(hero.targetCrystalCount)"
        hitPointsLabel.string = "Hit Points: \(hero.hitPoints)"
        
	}
    
    
    override func update(delta: CCTime) {
        // Update items that need to be changed as often as possible
        // e.g. physics bodies, anything animated
        
        if endStageUI.visible{
        	return
        }
        
        if heroExited {
            showEndStage()
            return
        }
        
        let effectiveScrollSpeed = scrollSpeed * (heroIsDead() || hero.hasWon ? 0 : (hero.isJumping ? 2.5 : 1))
        
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - effectiveScrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
        hero.position = ccp(hero.position.x + effectiveScrollSpeed * CGFloat(delta), hero.position.y)
        
        if (hero.hasWon) {
            spawnSafeGroundIfNeeded()
            raiseSafeGroundIfNeeded()
            checkForHeroExit()
            
        } else if (heroIsDead()) {

            sinceHeroDeath += delta
            
            if (gameOverUI.visible == false) {
            	showEndStage()
            }
            
            if (dirgePlayed == false && sinceHeroDeath > 4){
                playDirge()
            }
            
        } else {

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
            removeBlackDragonIfNeeded()
            
            spawnRedDragonIfNeeded(delta)
        }
    }

    func loopTheGroundIfNeeded(){
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in grounds {
            let groundScreenPosition = screenPositionForNode(ground)
            let groundScaledContentWidth = ground.contentSize.width * CGFloat(ground.scaleX)
            let correctionForPixelBoundary = CGFloat(-1) // removes space between ground objects due to width scaling
            if groundScreenPosition.x <= (-groundScaledContentWidth) {
                ground.position = ccp((ground.position.x + groundScaledContentWidth * 2) + correctionForPixelBoundary, ground.position.y)
            }
        }
        
    }
    
    func removeAndSpawnPlatformIfNeeded(){
        for platform in Array(platforms.reverse()) {
            let platformScreenPosition = screenPositionForNode(platform)
            let platformScaledContentWidth = platform.contentSize.width * CGFloat(platform.scaleX)
            
            // platform moved past left side of screen?
            if platformScreenPosition.x < (-platformScaledContentWidth) {
                platform.removeFromParent()
                platforms.removeAtIndex(platforms.indexOf(platform)!)

				spawnNewPlatform()
                
                if (rollD100(successChance: 80)) {
                    spawnNewCrystal()
                }
                
                spawnBlackDragonIfPossible()
                
            }
        }
        
    }
    
    func removeCrystalsIfNeeded(){
        
        for crystal in Array(crystals.reverse()) {
            let crystalScreenPosition = screenPositionForNode(crystal)
            
            // crystal moved past left side of screen?
            if crystalScreenPosition.x < (-crystal.contentSize.width) {
                crystal.removeFromParent()
                crystals.removeAtIndex(crystals.indexOf(crystal)!)
            }
        }
    
    }
    
    func removeBlackDragonIfNeeded(){
        for dragon in Array(blackDragons.reverse()) {
            let dragonScreenPosition = screenPositionForNode(dragon)
            
            // dragon moved past left side of screen?
            if dragonScreenPosition.x < (-dragon.contentSize.width) {
                dragon.removeFromParent()
                blackDragons.removeAtIndex(blackDragons.indexOf(dragon)!)
            }
        }
        
    
    }
    
    
    func removeRedDragonIfNeeded(deltaTime:CCTime){
        if redDragon != nil  {
        
            let redDragonScreenPosition = screenPositionForNode(redDragon)
            
            // dragon moved off screen?
            if redDragonScreenPosition.x < (-redDragon.contentSize.width) {
                redDragon.removeFromParent()
                redDragon = nil
            }
        }
    }

    func spawnNewPlatform(){
        let platform = FloatingGround.spawn(relativeTo: lastPlatform, levelEnd:hero.hasWon)
        gamePhysicsNode.addChild(platform)
        platforms.append(platform)
        
        lastPlatform = platform
    }
    
    func spawnNewCrystal (){
        let crystal = Crystal.spawn(relativeTo: lastPlatform.position)

        gamePhysicsNode.addChild(crystal)
        crystals.append(crystal)

    }

    func spawnBlackDragonIfPossible(){
        if let blackDragon = lastPlatform.spawnBlackDragon() {
            blackDragon.zOrder = hero.zOrder + 5
            gamePhysicsNode.addChild(blackDragon)
            blackDragons.append(blackDragon)
        }
    }
    
    func spawnRedDragonIfNeeded(deltaTime:CCTime){
        sinceLastRedDragon += deltaTime
        if redDragon == nil  && !hero.isJumping && rollD100(successChance: 1) {
        
            redDragonSpawnPoint.x = hero.position.x - 200
            
            redDragon = RedDragon.spawn(relativeTo:redDragonSpawnPoint, rightToLeft:rollD100())
            redDragon.zOrder = hero.zOrder + 10
            gamePhysicsNode.addChild(redDragon)
            
            sinceLastRedDragon = 0
            
        }
    }
    
    func spawnSafeGroundIfNeeded(){
        if safeGround1 == nil && safeGround2 == nil {
            safeGround1 = SafeGround.spawn(relativeTo: ground1.position)
            safeGround2 = SafeGround.spawn(relativeTo: ground2.position)
            
            gamePhysicsNode.addChild(safeGround1)
            gamePhysicsNode.addChild(safeGround2)
            
        }

    }
    
    func raiseSafeGroundIfNeeded(){
        
        safeGround1.raise()
        safeGround2.raise()
        
    }
    
    func checkForHeroExit(){
        let distance1 = verticalDistance(fromNodeA: hero, toNodeB: safeGround1)
        let distance2 = verticalDistance(fromNodeA: hero, toNodeB: safeGround2)
        
        let heroIsOnSafeGround1 = distance1 > 0 && distance1 < distanceWhenStandingOnPlatform
        let heroIsOnSafeGround2 = distance2 > 0 && distance2 < distanceWhenStandingOnPlatform
        
        if safeGround1.fullyRaised && safeGround2.fullyRaised &&
            (heroIsOnSafeGround1 || heroIsOnSafeGround2) &&
        	!stageExitTriggered {
                
                hero.exitStage()
                stageExitTriggered = true
        }

        if (stageExitTriggered && !heroExited && hero.physicsBody.velocity.magnitude() <= 0){
			// Workaround for bug where the hero gets stuck in place
            hero.exitStage()
        }
        
    }
    
     func verticalDistance(fromNodeA nodeA:CCNode, toNodeB nodeB:CCNode) -> CGFloat {
        return nodeA.position.y - nodeB.position.y
    }
    
    func screenPositionForNode(node:CCNode) -> CGPoint {
        let nodeWorldPosition = gamePhysicsNode.convertToWorldSpace(node.position)
        let nodeScreenPosition = convertToNodeSpace(nodeWorldPosition)
        return nodeScreenPosition
    }
    
}
