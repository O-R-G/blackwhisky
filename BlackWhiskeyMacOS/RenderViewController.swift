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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        for i in 1...500 {
            let tmp = Int(i*5);
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(tmp)) { // change 2 to desired number of seconds
                let position = float2(Float(arc4random_uniform(800)),Float(arc4random_uniform(600)))
                let tuple = FloatTuple(position, float2(), float2(), float2(), float2())
                self.renderer.updateInteraction(points: tuple, in: self.metalView)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { // change 2 to desired number of seconds
                    let positionNext = float2(position.x+100, position.y)
                    let tupleNext = FloatTuple(positionNext, float2(), float2(), float2(), float2())
                    self.renderer.updateInteraction(points: tupleNext, in: self.metalView)
                    
                }
            }
        }
    }
    
    deinit {
        NSEvent.removeMonitor(eventMonitor as Any)
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = event.locationInWindow
        
        let position = float2(Float(point.x), Float(metalView.bounds.height - point.y))
        let tuple = FloatTuple(position, float2(), float2(), float2(), float2())
        renderer.updateInteraction(points: tuple, in: metalView)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let point = event.locationInWindow
        
        let position = float2(Float(point.x), Float(metalView.bounds.height - point.y))
        let tuple = FloatTuple(position, float2(), float2(), float2(), float2())
        renderer.updateInteraction(points: tuple, in: metalView)
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
