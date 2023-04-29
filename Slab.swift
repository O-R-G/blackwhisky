//
//  Slab.swift
//
//  Created by Andrei-Sergiu Pițiș on 19/05/2017.
//  https://github.com/andreipitis/FluidDynamicsMetal
//
//  Modified by Eric Li on 7/25/18.
//  Copyright © 2018 O-R-G inc. All rights reserved.
//

import Foundation
import Metal

class Slab {
    var ping: MTLTexture!
    var pong: MTLTexture!
    
    init(width: Int, height: Int, format: MTLPixelFormat = .rgba16Float, usage: MTLTextureUsage = .unknown, name: String? = nil) {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = format
        textureDescriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.renderTarget.rawValue)
        textureDescriptor.width = width
        textureDescriptor.height = height
        /*
            textureDescriptor.storageMode cannot be private for apple silicon
            extensive debugging eventually resolved the issue by referencing
            https://github.com/andreipitis/FluidDynamicsMetal/commit/1a1d5695c8c39e8b95cfa15a64266179eb5335e5
        */
        // textureDescriptor.storageMode = .private
        
        ping = MetalDevice.createTexture(descriptor: textureDescriptor)
        pong = MetalDevice.createTexture(descriptor: textureDescriptor)
        
        ping.label = name
        pong.label = name
    }
    
    func swap() {
        let temp = ping
        ping = pong
        pong = temp
    }
}
