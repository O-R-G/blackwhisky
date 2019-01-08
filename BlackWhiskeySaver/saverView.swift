//
//  saverView.swift
//  BlackWhiskey
//
//  Created by david reinfurt on 1/2/18.
//  Copyright © 2018 O-R-G inc. All rights reserved.
//
//  http://blog.viacom.tech/2016/06/27/making-a-macos-screen-saver-in-swift-with-scenekit/
//

import ScreenSaver
import MetalKit

class saverView: ScreenSaverView {
    
    var renderer: Renderer!
    var metalView: MTKView!
    
    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0 / 30.0

        self.metalView = MTKView.init(frame: self.bounds, device: MetalDevice.sharedInstance.device)
        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
        
        for i in 1...500 {
            let tmp = Int(i*1000+1000);
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(tmp)) { // change 2 to desired number of seconds
                let position = float2(Float(arc4random_uniform(800)),Float(arc4random_uniform(600)))
                let tuple = FloatTuple(position, float2(), float2(), float2(), float2())
                self.renderer.updateInteraction(points: tuple, in: self.metalView)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(arc4random_uniform(2000)))) { // change 2 to desired number of seconds
                    let positionNext = float2(position.x+Float(arc4random_uniform(500)), position.y+Float(arc4random_uniform(500)))
                    let tupleNext = FloatTuple(positionNext, float2(), float2(), float2(), float2())
                    self.renderer.updateInteraction(points: tupleNext, in: self.metalView)
                    
                }
            }
        }

        //add it in as a subview
        self.addSubview(metalView)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
