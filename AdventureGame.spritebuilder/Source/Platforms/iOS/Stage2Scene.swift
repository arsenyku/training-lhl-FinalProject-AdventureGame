//
//  Stage2Scene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-13.
//  Copyright © 2015 Apportable. All rights reserved.
//

class Stage2Scene: AdventureScene {

    // Sprites
    weak var hero: HeroStage2!
    var snake : Snake!
    var bombs : [Bomb] = []

    // User Interaction

    var doubleTapDetector : UITapGestureRecognizer!
    weak var scoreLabel : CCLabelTTF!
    weak var hitPointsLabel : CCLabelTTF!
    
    override func heroIsDead() -> Bool {
        return hero.isDead
    }
    
    var heroHasWon: Bool {
        get {
	        return snake.isDead && heroIsDead() == false
        }
    }
    
    var snakeHasWon: Bool {
        get {
            return snake.isDead == false && heroIsDead()
        }
    }
    
    override func didLoadFromCCB() {
        super.didLoadFromCCB()
        
        replayScene = "Stage2Scene"
        nextScene = "WelcomeScene"
        
        let viewSize = CCDirector.sharedDirector().view.frame.size
        let heroStart = ccp(viewSize.width/2, viewSize.height/2)
        hero.position = heroStart
        hero.preStart()
        
        doubleTapDetector = UITapGestureRecognizer(target: self, action: Selector("placeTrap:"))
        doubleTapDetector.numberOfTapsRequired = 2
        doubleTapDetector.delegate = self
        CCDirector.sharedDirector().view.addGestureRecognizer(doubleTapDetector)

        snake = Snake.spawn(prey: hero)

        snake.parts.forEach { snakePart -> Void in
        	self.gamePhysicsNode.addChild(snakePart)
        }

        OALSimpleAudio.sharedInstance().playBg("SnakeTheme.mp3", loop: true)

    }

    // MARK: User Interaction
    
    func tapDetected(sender:UITapGestureRecognizer){
		if snakeHasWon || heroHasWon || heroIsDead() {
            return
        }
        
        let tapPoint = sender.locationInView(CCDirector.sharedDirector().view)
        hero.moveTo(point: tapPoint)
    }
    
    func placeTrap(sender:UITapGestureRecognizer){
        if snakeHasWon || heroHasWon || heroIsDead() {
            return
        }
        
        print ("place trap")
        let bomb = Bomb.spawn(on: hero.position)
        gamePhysicsNode.addChild(bomb)
        bombs.append(bomb)
    }
    
    // MARK: Collision checks
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, wall: CCNode!) -> Bool {
        print ("Ow")
        return true
    }
    
    func ccPhysicsCollisionPreSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, snakePart: SnakePart!) -> Bool {
        hero.hitByEnemy(snakePart)
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, bomb: CCNode!) -> Bool {
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, snakePart: SnakePart!, bomb: Bomb!) -> Bool {
       	if let bomb = bomb {
            bomb.removeFromParent()
            bombs.removeAtIndex(bombs.indexOf(bomb)!)
            snake.hitBy(bomb)
        }
        return false
    }
    
    // MARK: Update logic
    
    override func fixedUpdate(delta: CCTime) {

        // Update items that do not need to be changed on every frame
        // e.g. text labels, non-physics bodies, anything not animated or moving
        scoreLabel.string = "Snake Health: \(snake.health) / \(Snake.maxHealth)"
        hitPointsLabel.string = "Hit Points: \(hero.hitPoints)"
        
        if snakeHasWon || heroHasWon || heroIsDead() {

            if (gameOverUI.visible == false && endStageUI.visible == false) {
	            showEndStage()
            }
   
            if (heroIsDead()) {
                
                if (dirgePlayed == false) {
                    sinceHeroDeath += delta
                    
                    if (dirgePlayed == false && sinceHeroDeath > 4){
                        playDirge()
                    }
                }
            }
        
        }

        
        if endStageUI.visible || gameOverUI.visible {
            return
        }
        

        snake.moveForward(delta)
        
    }
    
    
    override func update(delta: CCTime) {
        // Update items that need to be changed as often as possible
        // e.g. physics bodies, anything animated
        

    }
    
    
    override func nextStage(sender: AnyObject?) {
        OALSimpleAudio.sharedInstance().stopBg()
        let gameplayScene = CCBReader.loadAsScene(nextScene)
        CCDirector.sharedDirector().presentScene(gameplayScene, withTransition: CCTransition(crossFadeWithDuration: 1.5))
    }


    // MARK: Helper
    
    func screenPositionForNode(node:CCNode) -> CGPoint {
        let nodeWorldPosition = gamePhysicsNode.convertToWorldSpace(node.position)
        let nodeScreenPosition = convertToNodeSpace(nodeWorldPosition)
        return nodeScreenPosition
    }
    
 
}