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
    
    /*
    // enter full screen and accept mouse events
    override func viewDidAppear() {
        let presOptions: NSApplication.PresentationOptions = [.fullScreen, .autoHideMenuBar]
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions: presOptions]
        view.enterFullScreenMode(NSScreen.main!, withOptions: optionsDictionary)
        view.wantsLayer = true
        
        self.view.window!.acceptsMouseMovedEvents = true
        
    }
    */
    
    override func viewDidAppear() {
        self.view.window!.canBecomeVisibleWithoutLogin = true
        self.view.window!.orderFrontRegardless()
        self.view.window!.level = NSWindow.Level(2147483631)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        /*
        // kill on mousemove
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            NSApplication.shared.terminate(self)
            return $0
        }
        */
        
        // run automatically
         startSwirl()
    }
    
    deinit {
        stopSwirl()
        NSEvent.removeMonitor(eventMonitor as Any)
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

    /*
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
    */
}
