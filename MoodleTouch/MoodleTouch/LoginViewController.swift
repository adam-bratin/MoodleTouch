//
//  ViewController.swift
//  Moodle
//
//  Created by Adam Bratin on 11/10/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate, OSSStatusReturnDelegate {
    @IBOutlet var serverURLField : UITextField!
    @IBOutlet var usernameField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var confirmPasswordField : UITextField!
    @IBOutlet var errorField : UITextField!
    @IBOutlet var editButton : UIButton!
    @IBOutlet var deleteButton : UIButton!
    @IBOutlet var createButton : UIButton!
    @IBOutlet var security : KeychainHandler! = KeychainHandler()
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    @IBAction func buttonClick(sender : AnyObject) {
        if(sender as UIButton == self.deleteButton) {
            self.security.deleteItemAsync(self.serverURLField.text)
            
        } else {
            if(self.passwordField.text == self.confirmPasswordField.text) {
                if(sender as UIButton == self.createButton) {
                    if(Server.createServer(self, withDomain: self.serverURLField.text, UsingUsername: self.usernameField.text, AndPassword: self.passwordField.text)) {
                        self.security.addItemAsync(self.serverURLField.text, withUsername: self.usernameField.text, andPassword: self.passwordField.text)
                    }
                } else if(sender as UIButton == self.editButton) {
                    if(Server.editServer(self, withDomain: self.serverURLField.text, UsingUsername: self.usernameField.text, AndPassword: self.passwordField.text)) {
                        self.security.updateItemAsync(self.serverURLField.text, withUsername: self.usernameField.text, andPassword: self.passwordField.text)
                    }
                }
            } else {
                self.errorField.text = "Error: your confirm password doesn't match"
            }
        }
    }
    
    func createAlert(title :String, message : String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.security.OSSStatusDelegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Delegates and data sources
    //MARK: Delegate Functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == self.serverURLField) {
            textField.resignFirstResponder();
            self.usernameField.becomeFirstResponder()
        } else if(textField == self.usernameField) {
            textField.resignFirstResponder()
            self.passwordField.becomeFirstResponder()
        } else if(textField == self.passwordField) {
            textField.resignFirstResponder()
            self.confirmPasswordField.becomeFirstResponder()
        } else if(textField == self.confirmPasswordField) {
            removeFirstResponders()
        }
        return false
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        removeFirstResponders()
    }
    
    func removeFirstResponders() {
        self.serverURLField.resignFirstResponder()
        self.usernameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
        self.confirmPasswordField.resignFirstResponder()
    }
    
    func reutrnOSStatus(results: [NSObject : AnyObject]!) {
        var outdic : NSDictionary? = NSDictionary(dictionary: results)
        if let result = outdic  {
            var type = result["type"] as String
            var status = result["status"] as NSNumber
            if(type == "delete" && status.intValue == noErr) {
                createAlert("success", message: "The server was deleted from save list")
                Server.deleteServer(self, withDomain: self.serverURLField.text)
            } else if(type == "delete") {
                Server.deleteServer(self, withDomain: self.serverURLField.text)
            }
            else if(type == "update" && status.intValue == noErr) {
                createAlert("Success", message: "You added server to saved list")
            } else if(type == "add" && status.intValue == noErr) {
                createAlert("Success", message: "You added server to saved list")
            } else if(type == "add") {
                Server.deleteServer(self, withDomain: self.serverURLField.text)
            }
        }
    }
}

