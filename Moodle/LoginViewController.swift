//
//  ViewController.swift
//  Moodle
//
//  Created by Adam Bratin on 11/10/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var serverURLField : UITextField!
    @IBOutlet var usernameField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var confirmPasswordField : UITextField!
    @IBOutlet var errorField : UITextField!
    @IBOutlet var editButton : UIButton!
    @IBOutlet var deleteButton : UIButton!
    @IBOutlet var createButton : UIButton!
    
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
            Server.deleteServer(self, withDomain: self.serverURLField.text)
            SecurityControl.deleteItem(self.serverURLField.text)
        } else {
            if(self.passwordField.text == self.confirmPasswordField.text) {
                if(sender as UIButton == self.createButton) {
                    if(Server.createServer(self, withDomain: self.serverURLField.text, UsingUsername: self.usernameField.text, AndPassword: self.passwordField.text)) {
                        if(SecurityControl.addItem(self.serverURLField.text, withUsername: self.usernameField.text, usingPassword: self.passwordField.text)) {
                            createAlert("Success", message: "You added server to saved list")
                        } else {
                            Server.deleteServer(self, withDomain: self.serverURLField.text)
                        }
                    }
                } else if(sender as UIButton == self.editButton) {
                    if(Server.editServer(self, withDomain: self.serverURLField.text, UsingUsername: self.usernameField.text, AndPassword: self.passwordField.text)) {
                        if(SecurityControl.updateItem(self.serverURLField.text, withUsername: self.usernameField.text, usingPassword: self.passwordField.text)) {
                            createAlert("Success", message: "You updated server to saved list")
                        } else {
                            Server.deleteServer(self, withDomain: self.serverURLField.text)
                        }
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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}

