//
//  saverView.swift
//  tetracono
//
//  Created by david reinfurt on 1/2/18.
//  Copyright © 2018 O-R-G inc. All rights reserved.
//
//  http://blog.viacom.tech/2016/06/27/making-a-macos-screen-saver-in-swift-with-scenekit/
//

import ScreenSaver
import SceneKit

class saverView: ScreenSaverView {
    
    var scnView: SCNView!
    var scale: CGFloat = 4.0
    var offset: CGFloat = 2.1
    var detail = 240
    var speed: Double = 4.0

    func createConeNode() -> SCNNode {
        let cone = SCNCone(topRadius: 0.0*scale, bottomRadius: 1.0*scale, height: 1.0*scale)
        cone.radialSegmentCount = detail
        // cone.firstMaterial?.diffuse.contents = NSColor.red
        cone.firstMaterial?.diffuse.contents = NSImage(pathAwareName: "texture.png")

// array of colors for materials
// but cone only has three "sides" to its geometry, so this doesnt help
// will have to either map a texture to it or perhaps override the SCNCone constructor
// see https://developer.apple.com/documentation/scenekit/scngeometry

/*
        let colors = [NSColor.red, NSColor.green]
        let materials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }

        cone.materials = materials
*/

        let coneNode = SCNNode(geometry: cone)

        return coneNode
    }
    
    func createBoxNode() -> SCNNode {
        let box = SCNBox(width: 1.0*scale, height: 1*scale, length: 1*scale, chamferRadius: 0.1)
        box.firstMaterial?.diffuse.contents = NSColor.green
        let boxNode = SCNNode(geometry: box)
        return boxNode
    }
    
    func prepareSceneKitView() {
        
        // create a new scene
        // let scene = SCNScene(pathAwareName: "ship.scn")!
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        // cameraNode.position = SCNVector3(x: 0, y: 0, z: 25)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
                
        // better handled in an array

        // cone north
        let coneNodeNorth = createConeNode()
        coneNodeNorth.position = SCNVector3(x: 0, y: offset, z: 0)
        coneNodeNorth.rotation = SCNVector4(x: 0, y: 0, z: 1, w: .pi)
        scene.rootNode.addChildNode(coneNodeNorth)

        // cone east
        let coneNodeEast = createConeNode()
        coneNodeEast.position = SCNVector3(x: offset, y: 0, z: 0)
        coneNodeEast.rotation = SCNVector4(x: 0, y: 0, z: 1, w: .pi/2)
        scene.rootNode.addChildNode(coneNodeEast)

        // cone south
        let coneNodeSouth = createConeNode()
        coneNodeSouth.position = SCNVector3(x: 0, y: -offset, z: 0)
        coneNodeSouth.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
        scene.rootNode.addChildNode(coneNodeSouth)
        
        // cone west
        let coneNodeWest = createConeNode()
        coneNodeWest.position = SCNVector3(x: -offset, y: 0, z: 0)
        coneNodeWest.rotation = SCNVector4(x: 0, y: 0, z: 1, w: -.pi/2)
        scene.rootNode.addChildNode(coneNodeWest)

// need to add pivot to change orientation before rotation
// https://developer.apple.com/documentation/scenekit/scnnode/1408044-pivot

        // box
        // let boxNode = createBoxNode()
        // scene.rootNode.addChildNode(boxNode)

        coneNodeNorth.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: -1, z: 0, duration: 1.0*speed)))
        coneNodeEast.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1.5*speed)))
        coneNodeSouth.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: -1, z: 0, duration: 2.0*speed)))
        coneNodeWest.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 3.0*speed)))
        
        // retrieve the SCNView
        let scnView = self.scnView
        
        // set the scene to the view
        scnView?.scene = scene
        
        // allows the user to manipulate the camera ( not needed on saver )
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView?.showsStatistics = true
        
        // fixes low FPS if you need it
        // scnView?.antialiasingMode = .None
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        
        //probably not needed, but cant hurt to check in case we re-use this code later
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        //initialize the sceneKit view
        // openGL performs better on SS + SceneKit w/ one monitor, but Metal (default) works best on two, so using Metal
        let useopengl = [SCNView.Option.preferredRenderingAPI.rawValue: NSNumber(value: SCNRenderingAPI.openGLCore32.rawValue)]
        self.scnView = SCNView.init(frame: self.bounds, options: useopengl)
        /*        
        self.scnView = SCNView.init(frame: self.bounds)
        */
        
        //prepare it with a scene
        prepareSceneKitView()
        
        //set scnView background color
        scnView.backgroundColor = NSColor.black
        
        //add it in as a subview
        self.addSubview(self.scnView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
