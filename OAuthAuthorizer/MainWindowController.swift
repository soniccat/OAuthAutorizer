//
//  MainWindowController.swift
//  OAuthAuthorizer
//
//  Created by Alexey Glushkov on 01.05.15.
//  Copyright (c) 2015 Alexey Glushkov. All rights reserved.
//

import Cocoa
import AppKit
import WebKit

protocol MainWindowControllerDelegate {
    func mainWindowController(controller:MainWindowController, authorizedWithString string:String)
    func mainWindowController(controller:MainWindowController, authorizeError error:NSError)
    func mainWindowControllerWindowClosed(controller:MainWindowController)
}

class MainWindowController: NSWindowController {

    var redirectUrl: String?
    var delegate: MainWindowControllerDelegate!
    
    @IBOutlet var webView: WebView!
    
    override func windowWillLoad() {
        super.windowWillLoad();
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        assert(webView != nil, "webView check")
        assert(delegate != nil, "delegate check")
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        centerWindow(CGSizeMake(600, 600))
        self.window?.disableSnapshotRestoration()
        self.window?.level = kCGFloatingWindowLevelKey
        
    }
    
    func centerWindow(windowSize:CGSize) {
        var screenRect = NSScreen.mainScreen()?.frame;
        
        var xPos = CGRectGetMidX(screenRect!) - windowSize.width/2.0;
        var yPos = CGRectGetMidY(screenRect!) - windowSize.height/2.0;
        var windowFrame = CGRectMake(xPos, yPos, windowSize.width, windowSize.height)
        
        self.window?.setFrame(windowFrame, display: true)
    }
    
    func windowWillClose(notification: NSNotification) {
        delegate.mainWindowControllerWindowClosed(self)
    }
    
    func requestAuth(string:String) {
        var urlRef = NSURL(string: string)
        
        if let url = urlRef {
            requestAuth(url:url)
        } else {
            var resultString = String(format: "wrong url %@", arguments: [string])
            finishWithError(AuthError.WrongUrl, string: resultString);
        }
    }
    
    func requestAuth(#url:NSURL) {
        var parametersRef = url.parameters
        if let parameters = parametersRef {
            redirectUrl = parameters["redirect_uri"] as! String?
        }
        
        if (redirectUrl != nil) {
            var request = NSURLRequest(URL: url);
            webView.mainFrame.loadRequest(request)
        } else {
            var resultString = String(format: "redirect_uri hasn't found %@", arguments: [url])
            finishWithError(AuthError.RedirectUrlIsMissing, string: resultString);
        }
    }
    
    func finishWithError(code:AuthError, string:String) {
        var resultString = String(format: "error: %@", [string])
        self.delegate.mainWindowController(self, authorizeError: NSError(domain: Domain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey:resultString]));
    }
    
    override func webView(sender: WebView!,
        didFailLoadWithError error: NSError!,
        forFrame frame: WebFrame!) {
            
    }
    
    override func webView(webView: WebView!,
        decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!,
        request: NSURLRequest!,
        frame: WebFrame!,
        decisionListener listener: WebPolicyDecisionListener!) {
            if (request.URL!.absoluteString!.hasPrefix(self.redirectUrl!)) {
                listener.ignore();
                self.delegate.mainWindowController(self, authorizedWithString: request.URL!.absoluteString!);
            } else {
                listener.use();
            }
            
            listener.use();
    }
}
