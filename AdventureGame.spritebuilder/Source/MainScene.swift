import Foundation

class MainScene: CCNode {

    var scrollSpeed : CGFloat = 80
	weak var gamePhysicsNode : CCPhysicsNode!
    
    weak var ground1 : CCSprite!
    weak var ground2 : CCSprite!
    var grounds = [CCSprite]()  // initializes an empty array
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
        grounds.append(ground1)
        grounds.append(ground2)
    }

    override func update(delta: CCTime) {
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)

        // Fix black-line artifacts from looping environment
        let scale = CCDirector.sharedDirector().contentScaleFactor
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
