//
//  AppDelegate.swift
//  OAuthAuthorizer
//
//  Created by Alexey Glushkov on 01.05.15.
//  Copyright (c) 2015 Alexey Glushkov. All rights reserved.
//

import Cocoa

let Domain = "OAuthAuthorizer"
enum AuthError: Int {
    case WrongUrl = 1
    case RedirectUrlIsMissing = 2
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MainWindowControllerDelegate {

    var playgroundWindowController : MainWindowController! = nil;

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        showPlaygroundWindow();
        
        var urlRef = commandArgument(1);
        if let url = urlRef {
            requestAuth(url);
        } else {
            print("An oauth url is expected as the first argument")
            closeApp()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func showPlaygroundWindow() {
        if (playgroundWindowController == nil) {
            playgroundWindowController = MainWindowController(windowNibName: "MainWindow");
            playgroundWindowController.delegate = self
        }
        
        playgroundWindowController.showWindow(self);
    }
    
    func requestAuth(url:String) {
        playgroundWindowController.requestAuth(url);
    }
    
    func requestUrl() -> String? {
        return commandArgument(0)
    }
    
    func commandArgument(index: uint) -> String? {
        var result:String? = nil;
        if (index < uint(Process.argc)) {
            result = String.fromCString(Process.unsafeArgv[Int(index)])
        }
        
        return result;
    }
    
    // MainWindowControllerDelegate
    
    func mainWindowController(controller:MainWindowController, authorizedWithString string:String) {
        print(string)
        closeApp();
    }
    
    func mainWindowController(controller:MainWindowController, authorizeError error:NSError) {
        print(error.description)
        closeApp()
    }
    
    func mainWindowControllerWindowClosed(controller:MainWindowController) {
        closeApp()
    }
    
    func closeApp() {
        NSApplication.sharedApplication().terminate(self);
    }
}

