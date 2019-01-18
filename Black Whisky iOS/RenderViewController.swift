//
//  ViewController.swift
//  BlackWhiskey
//
//  Created by Eric Li on 1/8/19.
//  Copyright © 2019 O-R-G inc. All rights reserved.
//

import UIKit
import MetalKit

let MaxBuffers = 3

class RenderViewController: UIViewController {
    
    var renderer: Renderer!
    var metalView: MTKView {
        return view as! MTKView
    }
    
    weak var update: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
        
        metalView.isExclusiveTouch = true
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(doubleTapGesture)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeSource))
        gestureRecognizer.numberOfTapsRequired = 2
        gestureRecognizer.numberOfTouchesRequired = 2
        view.addGestureRecognizer(gestureRecognizer)
        
        // startSwirl()
    }
    
    deinit {
        stopSwirl()
        NotificationCenter.default.removeObserver(self)
    }
    
    func reset(milliseconds: Int) {
        
        /*
         reset the metalView every milliseconds
         wipes the screen and starts metalView from scratch
         avoids too much fluid velocity
         */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            self.renderer = Renderer(metalView: self.metalView)
            self.metalView.delegate = self.renderer
            self.startSwirl()
            self.reset(milliseconds: milliseconds)
            print("** reset **")
        }
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
        
        let width = UInt32(Float(self.view.bounds.width))   // use self.view for MacOS
        let height = UInt32(Float(self.view.bounds.height))
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
            // print(position_next.x, position_next.y)
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
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("Got Memory Warning")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let positions = touches.map { (touch) -> float2 in
            let position = touch.location(in: touch.view)
            return float2(Float(position.x), Float(position.y))
        }
        
        let tupleSize = MemoryLayout<FloatTuple>.size
        let arraySize = MemoryLayout<float2>.size * positions.count
        
        let tuple = malloc(tupleSize).assumingMemoryBound(to: FloatTuple.self)
        
        memset(tuple, 0, tupleSize)
        memcpy(tuple, positions, arraySize)
        
        renderer.updateInteraction(points: tuple.pointee, in: metalView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let positions = touches.map { (touch) -> float2 in
            let position = touch.location(in: touch.view)
            return float2(Float(position.x), Float(position.y))
        }
        let tupleSize = MemoryLayout<FloatTuple>.size
        let arraySize = MemoryLayout<float2>.size * positions.count
        
        let tuple = malloc(tupleSize).assumingMemoryBound(to: FloatTuple.self)
        
        memset(tuple, 0, tupleSize)
        memcpy(tuple, positions, arraySize)
        
        renderer.updateInteraction(points: tuple.pointee, in: metalView)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer.updateInteraction(points: nil, in: metalView)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer.updateInteraction(points: nil, in: metalView)
    }
    
    @objc func changeSource() {
        renderer.nextSlab()
    }
    
    @objc final func doubleTap() {
        metalView.isPaused = !metalView.isPaused
    }
    
    @objc final func willResignActive() {
        metalView.isPaused = true
    }
    
    @objc final func didBecomeActive() {
        metalView.isPaused = false
    }
}

