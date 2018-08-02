//
//  NSImageExtensions.swift
//  MySwiftScreenSaver
//
//  Created by Hill, Michael on 7/1/16.
//  Copyright © 2016 Hill, Michael. All rights reserved.
//
//  http://blog.viacom.tech/2016/06/27/making-a-macos-screen-saver-in-swift-with-scenekit/
//

import Cocoa

extension Bundle {
    static func pathAwareBundle() -> Bundle {
        return Bundle(for:object_getClass(saverView.self)!)
    }
}
