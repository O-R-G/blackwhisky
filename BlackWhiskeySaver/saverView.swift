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

        //add it in as a subview
        self.addSubview(metalView)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
