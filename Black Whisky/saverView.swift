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
    
    weak var update: Timer?
    
    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0 / 30.0

        self.metalView = MTKView.init(frame: self.bounds, device: MetalDevice.sharedInstance.device)
        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
        self.addSubview(metalView)
        startSwirl()
    }
        
    func startSwirl() {
        
        /*
            swirl is given a random starting position, angle, and speed
            then updates itself on an NSTimer until dispatchque stops updates
            then cues another swirl and starts again ...

            interval    how often update timer fires {0.1 ... 0.01}
            increment   x_ increment (speed of swirl)
            duration    how long to run update timer
            pause       time before next swirl
            x_          x offset each update
            y_          y offset each update
            y_max       limit to keep y_ from crashing .metal  
        */
        
        // 0. init
        
        let interval = 0.05
        var increment = 10.0
        let duration = 1000 
        let pause = 5000
        
        // 1. set angle & quadrant
        
        var x_dir: Int
        var y_dir: Int
        let theta = Float.random(in: 0 ..< 2 * .pi)
        switch theta {
            case 0.0 ..< (.pi/2):
                x_dir = 1
                y_dir = -1
            case (.pi/2) ..< .pi:
                x_dir = 1
                y_dir = 1
            case .pi ..< (3 * .pi/2):
                x_dir = -1
                y_dir = 1
            case (3 * .pi/2) ..< (2 * .pi):
                x_dir = -1
                y_dir = -1
            default:
                x_dir = 1
                y_dir = 1
        }
        // print(theta, x_dir, y_dir)
        
        // 2. set starting position
        
        let width = UInt32(Float(self.bounds.width))
        let height = UInt32(Float(self.bounds.height))
        let position_start = float2(Float(arc4random_uniform(width)),Float(arc4random_uniform(height)))
        var position_next = position_start
        var x_ = Float(0.0);
        var y_ = Float(0.0);
        let y_max = Float(height) * Float(10.0)
        
        // 3. set update timer
        
        update?.invalidate()
        update = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] _ in

            increment *= 1.05
            x_ += (Float(increment) * Float(x_dir))
            y_ = self!.y_(x_: x_, theta: theta) * Float(y_dir)
            position_next.x = position_start.x + x_
            position_next.y = position_start.y + y_
            position_next.y = min(max(position_next.y, Float(Float(y_max) * -1.0)), Float(y_max))

            self!.renderer.updateInteraction(points: FloatTuple(position_next, float2(), float2(), float2(), float2()), in: self!.metalView)
            print(position_next.x, position_next.y)
        })
        
        // 4. stop update timer after duration, wait (pause) & start new
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(duration)) {
            self.stopSwirl()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(pause)) {
                self.startSwirl()
            }
        }
    }
    
    func y_(x_: Float, theta: Float) -> Float {
        let y = (sin(theta) / cos(theta)) * x_
        return y.magnitude
    }
    
    func stopSwirl() {
        update?.invalidate()
        print("/")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
