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
    var bombs : [Bomb] = []

    // User Interaction
    var tapDetector : UITapGestureRecognizer!
    var doubleTapDetector : UITapGestureRecognizer!
    weak var scoreLabel : CCLabelTTF!
    weak var hitPointsLabel : CCLabelTTF!
    weak var soundToggleButton : CCButton!
    weak var endStageUI: CCNode!
    weak var gameOverUI: CCNode!
    weak var nextStageButton: CCButton!
    weak var replayStageButton: CCButton!
    weak var replayAfterDeathButton: CCButton!
    
    // Scene state
    var soundOn:Bool = false
    
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        
        let viewSize = CCDirector.sharedDirector().view.frame.size
        let heroStart = ccp(viewSize.width/2, viewSize.height/2)
        hero.position = heroStart
        hero.preStart()
        
        gamePhysicsNode.collisionDelegate = self
        
        tapDetector = UITapGestureRecognizer(target: self, action: Selector("tapDetected:"))
        tapDetector.numberOfTapsRequired = 1
        tapDetector.delegate = self
        CCDirector.sharedDirector().view.addGestureRecognizer(tapDetector)

        doubleTapDetector = UITapGestureRecognizer(target: self, action: Selector("placeTrap:"))
        doubleTapDetector.numberOfTapsRequired = 2
        doubleTapDetector.delegate = self
        CCDirector.sharedDirector().view.addGestureRecognizer(doubleTapDetector)

        snake = Snake.spawn(prey: hero)

        snake.parts.forEach { snakePart -> Void in
        	self.gamePhysicsNode.addChild(snakePart)
        }

        let audio = OALSimpleAudio.sharedInstance()
        audio.stopEverything()
        audio.muted = true
        audio.bgVolume = 0.25
        audio.playBg("SnakeTheme.mp3", loop: true)

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
        if let soundToggleButton = sender as? CCButton {
            
            soundOn = !soundOn
            soundToggleButton.selected = soundOn
            
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
        let gameplayScene = CCBReader.loadAsScene("Stage2Scene")
        CCDirector.sharedDirector().replaceScene(gameplayScene)
    }
    
    func nextStage(sender: AnyObject?) {
        OALSimpleAudio.sharedInstance().stopBg()
        let gameplayScene = CCBReader.loadAsScene("WelcomeScene")
        CCDirector.sharedDirector().replaceScene(gameplayScene)
        
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
        print ("planted")
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, snakePart: SnakePart!, bomb: Bomb!) -> Bool {
        bomb.removeFromParent()
        bombs.removeAtIndex(bombs.indexOf(bomb)!)
        snake.hitBy(bomb)
        return true
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
    
    func rollD100(successChance chance:Int = 50) -> Bool {
        return Float.random(min: 0, max: 1, precision:2) < (Float(chance)/100)
    }

    // MARK: Helpers
    
    func playSound() {
        OALSimpleAudio.sharedInstance().muted = false
    }
    
    func stopSound() {
        OALSimpleAudio.sharedInstance().muted = true
        
    }

}