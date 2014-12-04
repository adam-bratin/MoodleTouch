//
//  webViewController.swift
//  Moodle
//
//  Created by Adam Bratin on 11/13/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import WebKit

class webViewController: UIViewController, WKNavigationDelegate, UIAlertViewDelegate, UITextFieldDelegate, KeychainResultReturnDelegate {
    var domain : String = ""
    var creds : Dictionary<String,String> = Dictionary<String,String>()
    var startTouchID : Bool = false

    @IBOutlet var mNavigationController : MoodleNavigationController!
    @IBOutlet var webView : WKWebView!
    @IBOutlet var stopLoadingButton : UIBarButtonItem!
    @IBOutlet var reloadButton : UIBarButtonItem!
    @IBOutlet var forwardButton : UIBarButtonItem!
    @IBOutlet var backwardButton : UIBarButtonItem!
    @IBOutlet var security : KeychainHandler! = KeychainHandler()
    
    @IBAction func reload(sender : AnyObject) {
        self.webView.reload()
    }
    @IBAction func stopLoad(sender : AnyObject) {
        self.webView.stopLoading()
    }
    @IBAction func forward(sender : AnyObject) {
        self.webView.goForward()
    }
    @IBAction func backward(sender : AnyObject) {
        self.webView.goBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mNavigationController = self.navigationController! as MoodleNavigationController
        self.security.ResultsDelegate = self
        self.initializeWebView()
        self.security.copyMatchingAsync(self.domain)
//        SecurityControl.evaluateTouch(self, withDomain: self.domain)
//        SecurityControl.loadItem(self.domain)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.webView.removeObserver(self, forKeyPath:Constants.progressID)
        self.webView.removeObserver(self, forKeyPath:Constants.URLID)
        self.webView.removeObserver(self, forKeyPath:Constants.loadingID)
        self.mNavigationController.URLField.enabled = false
        self.mNavigationController.URLField.hidden = true
        self.mNavigationController.loadProgress.hidden = true
    }
    
    func createLoginScript() {
        if let usr = creds["password"] {
            var password = creds["password"]
            var username = creds["username"]
            var script : String = "document.querySelectorAll(\"input[type='text']\")[0].value = \"\(username!)\"; \n"
            script += "document.querySelectorAll(\"input[type='password']\")[0].value = \"\(password!)\"; \n"
            script += "document.querySelectorAll(\"input[type='password']\")[0].parentNode.submit(); \n"
            script += "var allLinks = document.getElementsByTagName(\"a\"); \n"
            script += "for (i=0; i<allLinks.length; i++) { \n"
            script += "allLinks[i].onclick = null; \n"
            script += "allLinks[i].target = \"_self\"; \n"
            script += "} \n"
            var userScript : WKUserScript = WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
            self.webView.configuration.userContentController.addUserScript(userScript)
            self.webView.reload()
        } else {
//            SecurityControl.evaluateTouch(self, withDomain: domain)
        }
    }
    
    func initializeWebView() {
        var userContentController = WKUserContentController()
        var configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame:view.frame, configuration: WKWebViewConfiguration())
        self.webView.navigationDelegate = self;
        self.webView.addObserver(self, forKeyPath: Constants.progressID, options: NSKeyValueObservingOptions.New, context: nil)
        self.webView.addObserver(self, forKeyPath: Constants.URLID, options: NSKeyValueObservingOptions.New, context: nil)
        self.webView.addObserver(self, forKeyPath: Constants.loadingID, options: NSKeyValueObservingOptions.New, context: nil)
        self.mNavigationController.URLField.hidden = false
        self.mNavigationController.loadProgress.hidden = false
        self.mNavigationController.URLField.enabled = true
        self.mNavigationController.URLField.returnKeyType = UIReturnKeyType.Go
        self.mNavigationController.URLField.delegate = self
        self.view.addSubview(self.webView)
        self.webView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.webView.allowsBackForwardNavigationGestures = true
        var url : NSURL! = NSURL(string: Constants.moodleURL + self.domain)
        var request :NSURLRequest! = NSURLRequest(URL: url)
        self.webView.loadRequest(request)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == alertView.cancelButtonIndex) {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            //check device password
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if (keyPath == Constants.progressID && object as NSObject == self.webView) {
            var progress : Float
            if(self.webView.estimatedProgress == 1) {
                progress = Float(0)
                self.mNavigationController.loadProgress.setProgress(progress, animated: false)
            }else {
                progress = Float(self.webView.estimatedProgress)
                self.mNavigationController.loadProgress.setProgress(progress, animated: true)
            }
            
        } else if(keyPath == Constants.URLID && object as NSObject == self.webView) {
            self.mNavigationController.URLField.text = self.webView.URL!.absoluteString!
        }
    }
    
    //MARK: - Delegates and data sources
    //MARK: Delegate Functions
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        var newWindow : Bool = navigationAction.targetFrame == nil
        if (navigationAction.targetFrame == nil) {
            self.webView.loadRequest(navigationAction.request)
        }
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var url : NSURL! = NSURL(string:self.mNavigationController.URLField.text)
        var request :NSURLRequest! = NSURLRequest(URL: url)
        self.webView.loadRequest(request)
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        removeFirstResponders()
    }
    
    func removeFirstResponders() {
        self.mNavigationController.URLField.resignFirstResponder()
    }
    
    func returnKeychainResults(results: [NSObject : AnyObject]!) {
        var outdic : NSDictionary? = NSDictionary(dictionary: results)
        if let result = outdic  {
            var username: String = result["acct"] as String
            var password : NSString! = NSString(data: result["v_Data"] as NSData!, encoding: NSUTF8StringEncoding)
            self.creds = [
                "username" : username,
                "password" : password]
            createLoginScript()
        }
    }
    
    func authenticationFailed() {
        self.webView.stopLoading()
        self.mNavigationController.popViewControllerAnimated(true)
    }
}
