//
//  AppDelegate.swift
//  Runner
//
//  Created by Eric Li on 7/25/18.
//  Copyright © 2018 O-R-G inc. All rights reserved.
//


import Cocoa
import ScreenSaver
import Metal

@NSApplicationMain
class AppDelegate: NSObject
{
    @IBOutlet weak var window: NSWindow!
    
    var view: ScreenSaverView!
    
    func setupAndStartAnimation()
    {
        let saverName = UserDefaults.standard.string(forKey: "saver") ?? "tetracono"
        guard let saverBundle = loadSaverBundle(saverName) else {
            NSLog("Can't find or load bundle for saver named \(saverName).")
            return
        }
        let saverClass = saverBundle.principalClass! as! ScreenSaverView.Type
        
        view = saverClass.init(frame: window.contentView!.frame, isPreview: false)
        view.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
        
        window.backingType = saverClass.backingStoreType()
        window.title = view.className
        window.contentView!.autoresizesSubviews = true
        window.contentView!.addSubview(view)
        
        view.startAnimation()
    }
    
    private func loadSaverBundle(_ name: String) -> Bundle?
    {
        let myBundle = Bundle(for: AppDelegate.self)
        let saverBundleURL = myBundle.bundleURL.deletingLastPathComponent().appendingPathComponent("\(name).saver", isDirectory: true)
        let saverBundle = Bundle(url: saverBundleURL)
        saverBundle?.load()
        return saverBundle
    }
    
    func restartAnimation()
    {
        if view.isAnimating {
            view.stopAnimation()
        }
        view.startAnimation()
    }
    
    @IBAction func showPreferences(_ sender: NSObject!)
    {
//        window.beginSheet(view.configureSheet()!, completionHandler: nil)
    }
    
}


extension AppDelegate: NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        MTLCopyAllDevices() // so that Xcode knows we're running a Metal app...
        setupAndStartAnimation()
    }
}


extension AppDelegate: NSWindowDelegate
{
    func windowWillClose(_ notification: Notification)
    {
//        NSApplication.shared().terminate(window)
    }
    
    func windowDidResize(_ notification: Notification)
    {
    }
    
    func windowDidEndSheet(_ notification: Notification)
    {
        restartAnimation()
    }
}
