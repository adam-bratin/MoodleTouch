//
//  webViewController.swift
//  Moodle
//
//  Created by Adam Bratin on 11/13/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import WebKit

class webViewController: UIViewController, WKNavigationDelegate, NSURLConnectionDelegate, UIAlertViewDelegate {
    var domain : String = ""
    var creds : Dictionary<String,String> = Dictionary<String,String>()
    var startTouchID : Bool = false
    @IBOutlet var webView : WKWebView!
    
//    init(domainNew: String) {
//        domain = domainNew
//        super.init(nibName: nil, bundle: nil);
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        SecurityControl.evaluateTouch(self, withDomain: self.domain)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPage() {
        if let usr = creds["password"] {
            var password = creds["password"]
            var username = creds["username"]
            var theConfiguration = WKWebViewConfiguration()
            var source : String = "document.getElementById(username).set(\"value\",\(username)); \n"
            source += "document.getElementById(password).set(\"value\",\(password)); \n"
            source += "document.getElementById(fm1).submit(); \n"
            var userScript = WKUserScript(source: source, injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
            
            var userContentController = WKUserContentController()
            userContentController.addUserScript(userScript)
            
            var configuration = WKWebViewConfiguration()
            configuration.userContentController = userContentController
            self.webView = WKWebView(frame:view.frame, configuration: WKWebViewConfiguration())
            webView.navigationDelegate = self;
            view.addSubview(webView)
            var url : NSURL! = NSURL(string: Constants.moodleURL + self.domain)
            var request :NSURLRequest! = NSURLRequest(URL: url)
            webView.loadRequest(request)
        } else {
            SecurityControl.evaluateTouch(self, withDomain: domain)
        }
    }
    
    
//    func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
//        
//        println("HERE")
//        if (challenge.previousFailureCount == 0){
//            
//            //        var authentication: NSURLCredential = (user:password:persistence:)
//        }
//    }
//    
//    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
//        return true
//    }
//    
//    func connection(connection:NSURLConnection!, willSendRequestForAuthenticationChallenge challenge:NSURLAuthenticationChallenge!) {
//        println("HERE")
//        if (challenge.previousFailureCount == 0){
//            
//            //    var authentication: NSURLCredential = (user:password:persistence:)
//        } else {
////            challenge.sender(cancelAuthenticationChallenge:challenge)
//        }
//    }
//    
//    func connection(connection : NSURLConnection!, didReceiveResponse response : NSURLResponse) {
//        let url : NSURL! = NSURL(string: Constants.moodleURL + self.domain)
//        let request :NSURLRequest! = NSURLRequest(URL: url)
//        self.webView.loadRequest(request)
//    }
//    
//    func connectionShouldUseCredentialStorage(connection : NSURLConnection) -> Bool {
//        return false;
//    }
}
