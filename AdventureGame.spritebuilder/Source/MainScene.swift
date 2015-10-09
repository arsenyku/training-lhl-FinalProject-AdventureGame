import UIKit

class MainScene: CCNode, CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate {

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
    var soundOn = false
    
    
	// User interaction
    var tapDetector : UITapGestureRecognizer!
    weak var coordinatesLabel : CCLabelTTF!
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

        lastPlatformX = hero.position.x - platformSpacing
        lastPlatformY = minPlatformHeight
     
        for _ in 1...5{
            spawnNewPlatform(stageInit:true)
        }
        
        hero.zOrder = 100
        
        OALSimpleAudio.sharedInstance().muted = true
        OALSimpleAudio.sharedInstance().playBg("LavaTheme.mp3", loop: true)

    }

    // MARK: User Interaction
    
    func tapDetected(sender:UITapGestureRecognizer){
        if (heroIsJumping == false){
            hero.physicsBody.applyImpulse(ccp(0, jumpImpulse))
            playJumpSound()
            heroIsJumping = true
        }
		// id jump_Up = [CCJumpBy actionWithDuration:1.0f position:ccp(0, 200) height:50 jumps:1];
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
    
        
        coordinatesLabel.string = "HERO: \(hero.position.x), \(hero.position.y)"
    
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

        gamePhysicsNode.addChild(platform)
        platforms.append(platform)

        lastPlatformX = platform.position.x
        lastPlatformY = platform.position.y
        
    }
    
    // MARK: Helpers
    
    func playSound() {
		OALSimpleAudio.sharedInstance().muted = false
    }

    func stopSound() {
    	OALSimpleAudio.sharedInstance().muted = true
    
    }

    func playJumpSound(){
        OALSimpleAudio.sharedInstance().playEffect("LavaJump.wav")
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
