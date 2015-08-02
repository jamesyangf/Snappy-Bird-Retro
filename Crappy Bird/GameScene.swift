//
//  GameScene.swift
//  Crappy Bird
//
//  Created by James Yang on 8/1/15.
//  Copyright (c) 2015 James Yang. All rights reserved.
//

import SpriteKit
import Foundation

struct BitMasks{
    //in order of bitmask
    static let playerCategory: UInt32 = 0x1 << 0
    static let pipeCategory: UInt32 = 0x1 << 1
    static let gapCategory: UInt32 = 0x1 << 2
    static let bottomCategory: UInt32 = 0x1 << 3
    static let noneCategory: UInt32 = 0x1 << 4
    
}

//This will be used to set the z-position for what ever we add
enum Layer: CGFloat {
    case Background //0
    case Pipe //1
    case Ground //2
    case Player  //3
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let theDefault = NSUserDefaults.standardUserDefaults()
    
    //moving objects
    var movingObject = SKNode()
    
    //the background
    var bg = SKSpriteNode()
    var bgTexture = SKTexture(imageNamed: "background")
    var scaleBg = CGFloat(1.2)
    
    //the ground
    var ground = SKSpriteNode()
    var groundTexture = SKTexture(imageNamed: "ground")
    
    //the player
    var player = SKSpriteNode()
    var arrayOfPlayer = [SKTexture]()
    
    //the pipes
    var bottomPipe = SKSpriteNode()
    var topPipe = SKSpriteNode()
    
    // Game over if bird hits obsticals
    var gameOver = false
    
    //pipe Gap
    var pipeGap = CGFloat()
    
    //begin game
    var start = false
    
    //scoring
    var highScore = 0
    var highScoreLabel = SKLabelNode()
    var score = 0
    var scoreLabel = SKLabelNode()
    
    //tapImage
    var tapImage = SKSpriteNode()
    
    //Sound Features
    var playerFlap = SKAction.playSoundFileNamed("felpudoVoa.mp3", waitForCompletion: false)
    var playerHit = SKAction.playSoundFileNamed("felpudoHit.mp3", waitForCompletion: false)
    var playerScores = SKAction.playSoundFileNamed("nota1.mp3", waitForCompletion: false)

    
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -12.0)
        self.addChild(movingObject)
        
        self.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0,y: frame.height/12), toPoint: CGPoint(x: frame.width,y: frame.height/12))
        self.physicsBody?.friction = 0
        self.physicsBody?.categoryBitMask = BitMasks.bottomCategory
        self.physicsBody?.contactTestBitMask = BitMasks.playerCategory
        
        settingBackground()
        settingGround()
        settingPlayer()
        setUpScore()
        setUpHighScore()
        settingUpTapImage()
        
        runAction(SKAction.repeatActionForever(SKAction.sequence(
            [SKAction.runBlock(addingPipes),
                SKAction.waitForDuration(NSTimeInterval(2.0))])))
       
      
      
        
    }
    
    
    
    //scrolling background
    func settingBackground(){
        
        // Animates Background 3
        bg = SKSpriteNode(texture: bgTexture)
        bg.setScale(scaleBg)
        
        
        
        //Moves screen
        var moveBg = SKAction.moveByX(-bgTexture.size().width * scaleBg, y: 0, duration: 9)
        var replaceBg = SKAction.moveByX(bgTexture.size().width * scaleBg, y: 0, duration: 0)
        var moveAndReplace = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        //  Loops bgImage
        for var i:CGFloat=0; i<3; i++
        {
            bg = SKSpriteNode(texture: bgTexture)
            bg.setScale(scaleBg)
            bg.zPosition = Layer.Background.rawValue
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i * scaleBg, y: self.frame.height/2)
            //bg.alpha = 0.75
            bg.runAction(moveAndReplace)
            movingObject.addChild(bg)
        }
    }
    
    //scrooling ground
    func settingGround(){
        // Animates ground
        ground = SKSpriteNode(texture: groundTexture)
        ground.zPosition = Layer.Ground.rawValue
        
        
        //Moves screen
        var moveBg = SKAction.moveByX(-groundTexture.size().width * scaleBg, y: 0, duration: 9)
        var replaceBg = SKAction.moveByX(groundTexture.size().width * scaleBg, y: 0, duration: 0)
        var moveAndReplace = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))
        
        //  Loops groundImage
        for var i:CGFloat=0; i<3; i++
        {
            ground = SKSpriteNode(texture: groundTexture)
            ground.setScale(scaleBg)
            ground.zPosition = Layer.Ground.rawValue
            ground.position = CGPoint(x: groundTexture.size().width/2 + groundTexture.size().width * i * scaleBg, y: self.frame.height/64)
            //bg.alpha = 0.75
            ground.runAction(moveAndReplace)
            movingObject.addChild(ground)
        }

        
    }
    
    
    func settingUpTapImage(){
        
        var tapTexture = SKTexture(imageNamed: "flappyTap")
        tapImage = SKSpriteNode(texture: tapTexture)
        
        tapImage.position = CGPoint(x: player.position.x + 90, y: player.position.y - 30)
        tapImage.setScale(1.6)
        addChild(tapImage)
        
        
    }
    
    
    func settingPlayer(){
        
        player = SKSpriteNode(imageNamed: "frame-1")
        player.position = CGPointMake(self.size.width/2.5, self.size.height/2) //position the player
        player.zPosition = Layer.Player.rawValue
        
        //loops through all the animation
        for (var i = 1; i <= 3; i++)
        {
            arrayOfPlayer.append((SKTexture(imageNamed:"frame-\(i)")))
        }
        
        // animate wings - .01 is fast - sample at 0.1 - 0.05 these setting will repostion bird
        var animate = SKAction.animateWithTextures(arrayOfPlayer, timePerFrame: 0.07)
        var makePlayerAnimate = SKAction.repeatActionForever(animate)
        
        //runs the animation
        player.runAction(makePlayerAnimate)
        // Shrink bird add scale last
        player.setScale(0.4)
        self.addChild(player)
        
        //the pipeGap is 2.5 times the size of the player
        pipeGap = player.size.height*2.5
        
        
    }
    
    
    func addingPipes(){
        if start && !gameOver{
            var randomNum = arc4random() % UInt32(self.size.height / 3)
            var randomHeight = CGFloat(randomNum) - self.size.height / 4
            
            //pipe actions moving left
            var movePipe = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.size.width / 100))
            var removePipe = SKAction.removeFromParent()
            var pipeSequence = SKAction.sequence([movePipe, removePipe ])
            
            //The bottom pipe
            var bottomPipeTexture = SKTexture (imageNamed: "bottomPipe")
            bottomPipe = SKSpriteNode(texture: bottomPipeTexture)
            bottomPipe.size.width = 100
            bottomPipe.zPosition = Layer.Pipe.rawValue
            bottomPipe.position = CGPoint(x: self.size.width, y: randomHeight) //random height for the bottom
            bottomPipe.runAction(pipeSequence)
            
            //The top pipe
            var topPipeTexture = SKTexture(imageNamed: "topPipe")
            topPipe = SKSpriteNode(texture: topPipeTexture)
            topPipe.size.width = 100
            topPipe.zPosition = Layer.Pipe.rawValue
            topPipe.position = CGPoint(x: self.size.width, y:(bottomPipe.position.y + topPipe.size.height + pipeGap)) //the top pipe will follow the bottom pipe height with a gap
            topPipe.runAction(pipeSequence)
            
            
            // physical body of the Pipes
            bottomPipe.physicsBody = SKPhysicsBody(texture: bottomPipeTexture, size: bottomPipe.size)
            bottomPipe.physicsBody?.dynamic = false
            topPipe.physicsBody = SKPhysicsBody(texture: topPipeTexture, size: topPipe.size)
            topPipe.physicsBody?.dynamic = false
            
            
            // The gap between the pipes
            var gap = SKNode()
            gap.position = CGPoint(x: size.width+bottomPipe.size.width - 50, y: bottomPipe.position.y + bottomPipe.size.height/2 + pipeGap/2)
            gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1, pipeGap)) //the physics body of the gap
            gap.physicsBody?.dynamic = false
            gap.runAction(pipeSequence) //this will do the same action as the pipes
            
            //Setting the bit masks to the pipes and the gap for collision
            bottomPipe.physicsBody?.categoryBitMask = BitMasks.pipeCategory
            topPipe.physicsBody?.categoryBitMask = BitMasks.pipeCategory
            gap.physicsBody?.categoryBitMask = BitMasks.gapCategory
            
            bottomPipe.physicsBody?.contactTestBitMask = BitMasks.playerCategory //if gap contacts player
            topPipe.physicsBody?.contactTestBitMask = BitMasks.playerCategory
            gap.physicsBody?.contactTestBitMask = BitMasks.playerCategory
            
            
            //add the pipes and the gape to movingObject node
            movingObject.addChild(bottomPipe)
            movingObject.addChild(topPipe)
            movingObject.addChild(gap)
        }
        
    }
    
    func setUpScore(){
        
        // Post Score to game
        scoreLabel.fontName = "jabjai"
        scoreLabel.fontSize = 50
        scoreLabel.text = "0"
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - self.frame.size.height/4)
        //scoreLabel.alpha=0
        scoreLabel.zPosition=9
        self.addChild(scoreLabel)
    }
    
    func setUpHighScore(){
        
        // Post Score to game
        highScore = theDefault.integerForKey("highscore")
        highScoreLabel.fontName = "jabjai"
        highScoreLabel.fontSize = 50
        highScoreLabel.text = "\(highScore)"
        highScoreLabel.fontColor = UIColor.blackColor()
        highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - self.frame.size.height/7)
        //highScoreLabel.alpha=0.7
        highScoreLabel.zPosition=9
        self.addChild(highScoreLabel)
    }

    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        //player gets physics body
        
        if let touch = touches.first as? UITouch {
            if gameOver{
                touch.view.userInteractionEnabled = false
            }else{
                touch.view.userInteractionEnabled = true
                start = true
                tapImage.removeFromParent()
                player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/3)
                player.physicsBody?.dynamic = true
                player.physicsBody?.allowsRotation = false
            
                player.physicsBody?.velocity = CGVectorMake(0, 0)
                player.physicsBody?.applyImpulse(CGVectorMake(0, 9))
            
                //player BitMask
                player.physicsBody?.categoryBitMask = BitMasks.playerCategory
                player.physicsBody?.contactTestBitMask = BitMasks.pipeCategory
                player.physicsBody?.contactTestBitMask = BitMasks.gapCategory
                player.physicsBody?.contactTestBitMask = BitMasks.bottomCategory
                player.physicsBody?.collisionBitMask = BitMasks.noneCategory//the player does not collide with anything
                self.runAction(playerFlap)
                self.createParticles()

            }
        }
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else
        {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        //conditionals of what it hit
        if firstBody.categoryBitMask == BitMasks.playerCategory && secondBody.categoryBitMask == BitMasks.gapCategory{
            self.runAction(playerScores)
            score++
            scoreLabel.text = "\(score)"
            // Add a little visual feedback for the score increment
            scoreLabel.runAction(SKAction.sequence([SKAction.scaleTo(1.5, duration:NSTimeInterval(0.1)), SKAction.scaleTo(1.0, duration:NSTimeInterval(0.1))]))
            secondBody.node?.removeFromParent() //remove gapCategory
        
        }else if firstBody.categoryBitMask == BitMasks.playerCategory && secondBody.categoryBitMask ==
            
            BitMasks.pipeCategory{
            println("player hit log")
            if !gameOver {
                self.runAction(playerHit)
                gameOver = true
                movingObject.speed = 0 //everyting stops moving
            }

        }else if firstBody.categoryBitMask == BitMasks.playerCategory && secondBody.categoryBitMask == BitMasks.bottomCategory{
            if !gameOver {
                self.runAction(playerHit)
                gameOver = true
                movingObject.speed = 0 //everyting stops moving
            }

        }
    }
    //the rotating function, if the player's velocity is negative, the player will rotate in neg vice versa
    //player's rotation is affected by its velocty every way
    func rotation(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat{
        if( value > max )
        {
            return max
        } else if( value < min)
        {
            return min
        } else
        {
            return value
        }
        
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
       
        //making the player rotate up or down depending on its velocity
        if start{
            let num = player.physicsBody!.velocity.dy as CGFloat
            player.zRotation = self.rotation(-1, max: 0.5, value: num * 0.001)
        }
        
        // Making the game harder
        if(score >= 10 && score <= 20){
            pipeGap = player.size.height*2.3
        }
        if(score >= 21 && score <= 30){
            pipeGap = player.size.height*2.1
        }
        if(score >= 31 && score <= 50){
            pipeGap = player.size.height*1.9
        }
        if score >= 50{
            //pipe actions moving up and down
            pipeGap = player.size.height*1.9
            var moveUp = SKAction.moveToY(pipeGap , duration: NSTimeInterval(21.0))
            var moveDown = SKAction.moveToY(-pipeGap , duration: NSTimeInterval(3.0))
            bottomPipe.runAction(SKAction.repeatActionForever(SKAction.sequence([moveUp,moveDown])))
        }
        
        
        //theDefault.integerForKey("highscore")
        if score > theDefault.integerForKey("highscore") {
            theDefault.setInteger(score, forKey: "highscore")
            theDefault.synchronize()
             highScoreLabel.text = "\(score)"
        }
        
        if player.position.y <  0 - player.size.height {
            player.removeFromParent()
        }
    }
    
    //creating the particle for player
    func createParticles()
    {
        var leaves:SKTexture = SKTexture(imageNamed: "pena") //reusing the bird texture for now
        var emitLeaves:SKEmitterNode = SKEmitterNode()
        emitLeaves.particleTexture = leaves
        emitLeaves.position = CGPointMake(player.position.x+player.size.width/12,player.position.y+player.size.height/10)
        emitLeaves.particleBirthRate = 100
        emitLeaves.numParticlesToEmit = 7;
        emitLeaves.particleLifetime = 1.3
        
        emitLeaves.xAcceleration = 0
        emitLeaves.yAcceleration = 0
        
        emitLeaves.particleSpeed = 100
        emitLeaves.particleSpeedRange = 200
        
        emitLeaves.particleRotationSpeed = -10
        emitLeaves.particleRotationRange = 4
        emitLeaves.emissionAngle = 3
        emitLeaves.emissionAngleRange = 3.14
        
        emitLeaves.particleColorAlphaSpeed = 0.1
        emitLeaves.particleColorAlphaRange = 1
        
        emitLeaves.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1,0], times: [0,1])
        emitLeaves.particleScaleSequence = SKKeyframeSequence(keyframeValues: [1,0], times: [0,1])
        
        self.addChild(emitLeaves)
        
    }

    
}
