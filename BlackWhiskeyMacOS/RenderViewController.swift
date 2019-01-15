//
//  ViewController.swift
//  BlackWhiskeyMacOS
//
//  Created by Eric Li on 1/8/19.
//  Copyright © 2019 O-R-G inc. All rights reserved.
//

import AppKit
import MetalKit

class RenderViewController: NSViewController {
    var renderer: Renderer!
    var metalView: MTKView {
        return view as! MTKView
    }
    
    var eventMonitor: Any?
    weak var update: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        startSwirl()
    }
    
    deinit {
        stopSwirl()
        NSEvent.removeMonitor(eventMonitor as Any)
    }
    
    func startSwirl() {
        
        // init
        let interval = 0.0001
        let increment = Float(10)
        let duration = 1000
        let pause = 10000
        let width = UInt32(Float(self.view.bounds.width))
        let height = UInt32(Float(self.view.bounds.height))
        let position_start = float2(Float(arc4random_uniform(width)),Float(arc4random_uniform(height)))
        var position_next = position_start
        
        // set update timer
        update?.invalidate()
        update = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] _ in
            
            // update positions, render
            // position_next.x -= Float(arc4random_uniform(UInt32(increment)))
            // position_next.y -= Float(arc4random_uniform(UInt32(increments)))
            // increment *= 0.99999
            position_next.x += Float(increment)
            position_next.y -= Float(increment)
            // position_next.x *= 0.9999999999
            
            self!.renderer.updateInteraction(points: FloatTuple(position_next, float2(), float2(), float2(), float2()), in: self!.metalView)
            // print(position_next)
        })
        
        // stop update after duration, wait pause & then new
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(duration)) {
            self.stopSwirl()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(pause)) {
                self.startSwirl()
            }
        }
    }
    
    func stopSwirl() {
        update?.invalidate()
        print("-- stop swirl --")
    }

    override func mouseDragged(with event: NSEvent) {
        let point = event.locationInWindow
        
        var positions = [float2]()
        let points = 1
        let spacer = 50
        
        for index in 0...points-1 {
            let spacing = CGFloat(index * spacer)
            positions.append(float2(Float(point.x + spacing), Float(metalView.bounds.height - point.y + spacing)))
        }

        let tuple = FloatTuple(positions[0], float2(), float2(), float2(), float2())
        // let tuple = FloatTuple(positions[0], positions[1], positions[2], float2(), float2())
        // let tuple = FloatTuple(positions[0], positions[1], positions[2], positions[3], positions[4])
        
        renderer.updateInteraction(points: tuple, in: metalView)
        
        print(event.timestamp)
        print(positions)
    }
    
    override func mouseUp(with event: NSEvent) {
        renderer.updateInteraction(points: nil, in: metalView)
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            changePauseState()
        case 0x01:
            changeSource()
        case 0x18:  // =
            startSwirl()
        case 0x1B:  // -
            stopSwirl()
        default:
            break
        }
    }
    
    private func changeSource() {
        renderer.nextSlab()
    }
    
    private func changePauseState() {
        metalView.isPaused = !metalView.isPaused
    }
}
