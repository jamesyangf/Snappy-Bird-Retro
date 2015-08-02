//
//  MainMenu.swift
//  Crappy Bird
//
//  Created by Amy Yang on 8/1/15.
//  Copyright (c) 2015 James Yang. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    
    var bg = SKSpriteNode()
    var bgTexture = SKTexture(imageNamed: "background")
    var scaleBg = CGFloat(3.2)

    override func didMoveToView(view: SKView) {
        
        settingBackground()
        
    }

    
    //scrolling background
    func settingBackground(){
        
        // Animates Background 3
        bg = SKSpriteNode(texture: bgTexture)
        //  Position background
        bg.position = CGPointMake(self.size.width/2, self.size.height/2)
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
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i * scaleBg, y: self.frame.height/2)
            //bg.alpha = 0.75
            bg.runAction(moveAndReplace)
            self.addChild(bg)
        }
    }

    
    
    
    
    
}