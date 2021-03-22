//
//  AppDelegate.swift
//  Odysseyra1n
//
//  Created by 23 Aaron on 11/06/2020.
//  Copyright © 2020 23 Aaron. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func showHelp(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/23aaron/Betelguese/issues")!)
    }


}

