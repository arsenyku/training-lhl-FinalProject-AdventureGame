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
        let tapPoint = sender.locationInView(CCDirector.sharedDirector().view)

        hero.moveTo(point: tapPoint)
    }
    
    func placeTrap(sender:UITapGestureRecognizer){
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

        snake.moveForward(delta)
        
    }
    
    
    override func update(delta: CCTime) {
        // Update items that need to be changed as often as possible
        // e.g. physics bodies, anything animated
    }


    // MARK: Helper
    
    func screenPositionForNode(node:CCNode) -> CGPoint {
        let nodeWorldPosition = gamePhysicsNode.convertToWorldSpace(node.position)
        let nodeScreenPosition = convertToNodeSpace(nodeWorldPosition)
        return nodeScreenPosition
    }
    
 
}