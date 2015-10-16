//
//  Stage2Scene.swift
//  AdventureGame
//
//  Created by asu on 2015-10-13.
//  Copyright © 2015 Apportable. All rights reserved.
//

class Stage2Scene: CCNode, CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate {

    weak var gamePhysicsNode : CCPhysicsNode!
    
    // Sprites
    weak var hero : HeroStage2!
    var snake : Snake!

    // User Interaction
    var tapDetector : UITapGestureRecognizer!
    weak var scoreLabel : CCLabelTTF!
    weak var hitPointsLabel : CCLabelTTF!
    weak var soundToggleButton : CCButton!
    weak var endStageUI: CCNode!
    weak var gameOverUI: CCNode!
    weak var nextStageButton: CCButton!
    weak var replayStageButton: CCButton!
    weak var replayAfterDeathButton: CCButton!
    
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        let viewSize = CCDirector.sharedDirector().view.frame.size
        let heroStart = ccp(viewSize.width/2, viewSize.height/2)
        hero.position = heroStart
        
        gamePhysicsNode.collisionDelegate = self
        
        tapDetector = UITapGestureRecognizer(target: self, action: Selector("tapDetected:"))
        tapDetector.numberOfTapsRequired = 1
        tapDetector.delegate = self
        CCDirector.sharedDirector().view.addGestureRecognizer(tapDetector)

        snake = Snake.spawn(prey: hero)

        snake.parts.forEach { snakePart -> Void in
        	self.gamePhysicsNode.addChild(snakePart)
        }
        
        snake.addChasePoint(hero.position)
        
    }

    // MARK: User Interaction
    
    func tapDetected(sender:UITapGestureRecognizer){
        let tapPoint = sender.locationInView(CCDirector.sharedDirector().view)
        snake.addChasePoint(tapPoint)
        hero.moveTo(point: tapPoint)
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
//        if let toggleButton = sender as? CCButton {
//            
// 
//        }
    }
    
    func replayStage(sender: AnyObject?) {
        OALSimpleAudio.sharedInstance().stopBg()
        let gameplayScene = CCBReader.loadAsScene("Stage2Scene")
        CCDirector.sharedDirector().replaceScene(gameplayScene)
    }
    
    func nextStage(sender: AnyObject?) {
//        OALSimpleAudio.sharedInstance().stopBg()
//        let gameplayScene = CCBReader.loadAsScene("Stage2Scene")
//        CCDirector.sharedDirector().replaceScene(gameplayScene)
//        
    }
    
    
    // MARK: Collision checks
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: Hero!, wall: CCNode!) -> Bool {
       
        print ("Ow")
        return true
        
        
    }
    
    // MARK: Update logic
    
    override func fixedUpdate(delta: CCTime) {
        
        // Update items that do not need to be changed on every frame
        // e.g. text labels, non-physics bodies, anything not animated or moving
        scoreLabel.string = "Snake Health: \(snake.health) / \(Snake.maxHealth)"
        hitPointsLabel.string = "Hit Points: \(hero.hitPoints)"
        
        
        snake.moveForward(delta)
        
//        if (snake.isChasing == false) {
//	        snake.chaseHero(hero)
//        }
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
    
    func rollD100(successChance chance:Int = 50) -> Bool {
        return Float.random(min: 0, max: 1, precision:2) < (Float(chance)/100)
    }



}