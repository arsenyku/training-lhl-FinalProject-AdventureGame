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
        
        gamePhysicsNode.collisionDelegate = self
        
        tapDetector = UITapGestureRecognizer(target: self, action: Selector("tapDetected:"))
        tapDetector.numberOfTapsRequired = 1
        tapDetector.delegate = self
        CCDirector.sharedDirector().view.addGestureRecognizer(tapDetector)

                
    }

    // MARK: User Interaction
    
    func tapDetected(sender:UITapGestureRecognizer){
        let tapPoint = sender.locationInView(CCDirector.sharedDirector().view)
        print("run from \(hero.position) to \(tapPoint)")
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

    // MARK: Helper
    
    func screenPositionForNode(node:CCNode) -> CGPoint {
        let nodeWorldPosition = gamePhysicsNode.convertToWorldSpace(node.position)
        let nodeScreenPosition = convertToNodeSpace(nodeWorldPosition)
        return nodeScreenPosition
    }
    
    func directionVector(from from:CGPoint, to:CGPoint) -> CGPoint {
        let offset    = ccpSub(to, from);
//        let ratio     = offset.y/offset.x;
//        let targetX   = hero.contentSize.width/2 + self.contentSize.width;
//        let targetY   = (targetX*ratio) + from.y;
//        let targetPosition = ccp(targetX,targetY)
//        return targetPosition

        return offset
    }


}