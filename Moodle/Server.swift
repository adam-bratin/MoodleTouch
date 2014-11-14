//
//  Server.swift
//  Moodle
//
//  Created by Adam Bratin on 11/11/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Server: NSManagedObject {
    @NSManaged var domain : String
    
    class func createServer(viewController :LoginViewController, withDomain domain: String, UsingUsername username : String, AndPassword password : String) {
        if(viewController.serverURLField.text != "" && viewController.usernameField.text != "" && viewController.passwordField.text != "") {
            let fetchRequest = NSFetchRequest(entityName: Constants.serverItemIdentifier)
            let fetchPredicate : NSPredicate = NSPredicate(format: "domain == %@",  viewController.serverURLField.text)!
            fetchRequest.predicate = fetchPredicate
            var error: NSError? = nil
            let results = viewController.managedObjectContext!.executeFetchRequest(fetchRequest, error:&error) as [Server]
            if(error == nil) {
                if(results.count > 0) {
                    viewController.errorField.text = "Error: server already exists"
                } else {
                    let newItem : Server = NSEntityDescription.insertNewObjectForEntityForName(Constants.serverItemIdentifier, inManagedObjectContext: viewController.managedObjectContext!) as Server
                    newItem.domain = viewController.serverURLField.text
                    var error2 : NSError? = nil
                    if(viewController.managedObjectContext?.hasChanges == true && viewController.managedObjectContext?.save(&error2) == false) {
                        println("Save did not complete successfully. Error: \(error2?.localizedDescription)")
                    }
                    else {
                        createAlert("Success", message: "You added server to saved list", viewController: viewController)
                    }
                }
            } else {
                viewController.errorField.text = "Error: some fields are empty retry"
            }
        }
    }
    
    class func editServer(viewController :LoginViewController, withDomain domain: String, UsingUsername username : String, AndPassword password : String) {
        if(viewController.serverURLField.text != "" && viewController.usernameField.text != "" && viewController.passwordField.text != "") {
            let fetchRequest = NSFetchRequest(entityName: Constants.serverItemIdentifier)
            let fetchPredicate : NSPredicate = NSPredicate(format:"domain == %@", viewController.serverURLField.text)!
            fetchRequest.predicate = fetchPredicate
            var error: NSError? = nil
            
            let results = viewController.managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)
            if(results?.count > 0) {
                let server : Server = results?.first as Server
                server.domain = viewController.serverURLField.text
                var error2 : NSError? = nil
                if(viewController.managedObjectContext?.hasChanges == true && viewController.managedObjectContext?.save(&error2) == false) {
                    println("Save did not complete successfully. Error: \(error2?.localizedDescription)")
                } else {
                    createAlert("Success", message: "You changed the server settings", viewController: viewController)
                }
            } else {
                viewController.errorField.text = "Error: no server with that name"
            }
        } else {
            viewController.errorField.text = "Error: Some fields are empty retry"
        }
    }
    
    class func deleteServer(viewController :LoginViewController, withDomain domain: String) {
        if(viewController.serverURLField.text != "") {
            let fetchRequest = NSFetchRequest(entityName: Constants.serverItemIdentifier)
            let fetchPredicate : NSPredicate = NSPredicate(format:"domain == %@", viewController.serverURLField.text)!
            fetchRequest.predicate = fetchPredicate
            var error: NSError? = nil
            
            let results = viewController.managedObjectContext!.executeFetchRequest(fetchRequest, error:&error)
            if(results?.count > 0) {
                let server : Server = results?.first as Server
                viewController.managedObjectContext?.deleteObject(server)
                var error2 : NSError? = nil
                if(viewController.managedObjectContext?.hasChanges == true && viewController.managedObjectContext?.save(&error2) == false) {
                    println("Save did not complete successfully. Error: \(error2?.localizedDescription)")
                } else {
                    createAlert("Success", message: "You deleted the server", viewController: viewController)
                }
            } else {
                viewController.errorField.text = "Error: no server with that name"
            }
        } else {
            viewController.errorField.text = "Error: server URL is empty"
        }
    }
    
    private class func createAlert(title :String, message : String, viewController : UIViewController) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}
