//
//  AppDelegate.swift
//  JiraBridge
//
//  Created by Benjamin Johnson on 4/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Cocoa
import JiraKit
@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var connection: NSXPCConnection!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

