import UIKit

class MainScene: CCNode {

    let scrollSpeed : CGFloat = 50
    let jumpImpulse : CGFloat = 350
    
    weak var gamePhysicsNode : CCPhysicsNode!

    // Sprites
    weak var hero : CCSprite!
    weak var ground1 : CCSprite!
    weak var ground2 : CCSprite!
    var grounds = [CCSprite]()

    // Game State
    var sinceTouch : CCTime = 0
    
	// User interaction
    var tapDetector : UITapGestureRecognizer!
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        grounds.append(ground1)
        grounds.append(ground2)

        tapDetector = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
    	tapDetector.numberOfTapsRequired = 1
        
        CCDirector.sharedDirector().view.addGestureRecognizer(tapDetector)

    }
    
    func handleTap(sender:UITapGestureRecognizer){
        hero.physicsBody.applyImpulse(ccp(0, jumpImpulse))
        sinceTouch = 0
    }

    override func update(delta: CCTime) {
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
		hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        
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
    }
    
    
    
    
}
