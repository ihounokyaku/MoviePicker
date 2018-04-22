//
//  AppDelegate.swift
//  MoviePicker
//
//  Created by Dylan Southard on 2018/04/21.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa
import RealmSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        do {
            let _ = try Realm()
            print(Realm.Configuration.defaultConfiguration.fileURL)
        } catch {
            print("error initiating Realm \(error)")
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

