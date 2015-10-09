import UIKit

class MainScene: CCNode, CCPhysicsCollisionDelegate {

    let scrollSpeed : CGFloat = 70
    let jumpImpulse : CGFloat = 125
    let platformSpacing:CGFloat = 275

    //    let distanceBetweenObstacles : CGFloat = 160
    let minPlatformHeight:CGFloat = 65
    let maxPlatformHeight:CGFloat = 150


    weak var gamePhysicsNode : CCPhysicsNode!

    // Sprites
    weak var hero : CCSprite!
    weak var ground1 : CCSprite!
    weak var ground2 : CCSprite!
    var grounds = [CCSprite]()
    var platforms : [CCNode] = []

    // Game State
    var heroIsJumping = false
    var lastPlatformY : CGFloat = 0
    var lastPlatformX : CGFloat = 0
    
    
	// User interaction
    var tapDetector : UITapGestureRecognizer!
    weak var coordinatesLabel : CCLabelTTF!
    
    // MARK: Lifecycle
    
    func didLoadFromCCB() {
        userInteractionEnabled = true
		
        gamePhysicsNode.collisionDelegate = self
        
        grounds.append(ground1)
        grounds.append(ground2)

        tapDetector = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
    	tapDetector.numberOfTapsRequired = 1
        
        CCDirector.sharedDirector().view.addGestureRecognizer(tapDetector)

        lastPlatformX = hero.position.x - platformSpacing
        lastPlatformY = minPlatformHeight
     
        for _ in 1...5{
            spawnNewPlatform(stageInit:true)
        }
        
        hero.zOrder = 100
    }

    // MARK: User Interaction
    
    func handleTap(sender:UITapGestureRecognizer){
        if (heroIsJumping == false){
            print ("Jump start")
            hero.physicsBody.applyImpulse(ccp(0, jumpImpulse))
            heroIsJumping = true
        }
		// id jump_Up = [CCJumpBy actionWithDuration:1.0f position:ccp(0, 200) height:50 jumps:1];
    }

    // MARK: Game logic
    
    override func update(delta: CCTime) {
        let effectiveScrollSpeed = scrollSpeed * (heroIsJumping ? 2.5 : 1)
        
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
    
        
        coordinatesLabel.string = "HERO: \(hero.position.x), \(hero.position.y))"
    
        for platform in Array(platforms.reverse()) {
            let platformWorldPosition = gamePhysicsNode.convertToWorldSpace(platform.position)
            let platformScreenPosition = convertToNodeSpace(platformWorldPosition)
            let platformScaledContentWidth = platform.contentSize.width * CGFloat(platform.scaleX)
            
            // platform moved past left side of screen?
            if platformScreenPosition.x < (-platformScaledContentWidth) {
                platform.removeFromParent()
                platforms.removeAtIndex(platforms.indexOf(platform)!)
                
                spawnNewPlatform()
            }
        }
        
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, floatingGround: CCNode!) -> Bool {
        print("Collision test - hero: \(hero.position) - platform \(floatingGround.position)")
        
        let distanceWhenStandingOnGround:CGFloat = 40
        
        if (hero.position.y - floatingGround.position.y > distanceWhenStandingOnGround){
            // Hero is on top - accept collision
            return true
        } else {
            // Hero is below the platform - ignore the collision
            return false
        }
        
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, hero: CCNode!, floatingGround: CCNode!) {
        if (heroIsJumping) {
	        print("Jump end - hero: \(hero.position) - ground \(floatingGround.position)")
    	    heroIsJumping = false
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, ground: CCNode!) -> Bool {
        print("DEATH - hero: \(hero.position) - ground \(ground.position)")
        heroIsJumping = false
        return true
    }
    
    
    func spawnNewPlatform(stageInit stageInit:Bool = false) {
        
        // create and add a new platform
        let platform = CCBReader.load("FloatingGround")
        
        let yOffsetMax:Int = 80
        let yOffsetMin:Int = stageInit ? 0 : -yOffsetMax
        
        let newPlatformX = lastPlatformX + platformSpacing
        let newPlatformY = min(maxPlatformHeight, max(minPlatformHeight, lastPlatformY + CGFloat(randomInt(min:yOffsetMin, max:yOffsetMax))))
        
        platform.position = ccp(newPlatformX, newPlatformY)
        print("Spawning new platform at \(platform.position), z = \(platform.zOrder)")

        gamePhysicsNode.addChild(platform)
        platforms.append(platform)

        lastPlatformX = platform.position.x
        lastPlatformY = platform.position.y
        
    }
    
    func randomInt(min min:Int, max:Int) -> Int{
        assert(max >= min)
        return (min + Int(arc4random_uniform(UInt32(max - min + 1))))
    }
    
    func randomFloat(min min:Float, max:Float, precision:UInt32) -> Float{
        let precisionFactor = pow(Float(10),Float(precision))
        let adjustedMin = Int(min * precisionFactor)
        let adjustedMax = Int(max * precisionFactor)
        
        let result = Float(randomInt(min:adjustedMin, max:adjustedMax)) / precisionFactor
        return result
    }
    
    
}
