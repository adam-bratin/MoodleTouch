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
    
    class func createServer(viewController :LoginViewController, withDomain domain: String, UsingUsername username : String, AndPassword password : String) -> Bool {
        viewController.errorField.text = ""
        if(viewController.serverURLField.text != "" && viewController.usernameField.text != "" && viewController.passwordField.text != "") {
            let fetchRequest = NSFetchRequest(entityName: Constants.serverItemIdentifier)
            let fetchPredicate : NSPredicate = NSPredicate(format: "domain == %@",  viewController.serverURLField.text)!
            fetchRequest.predicate = fetchPredicate
            var error: NSError? = nil
            let results = viewController.managedObjectContext!.executeFetchRequest(fetchRequest, error:&error) as [Server]
            if(error == nil) {
                if(results.count > 0) {
                    viewController.errorField.text = "Error: server already exists"
                    return false
                } else {
                    let newItem : Server = NSEntityDescription.insertNewObjectForEntityForName(Constants.serverItemIdentifier, inManagedObjectContext: viewController.managedObjectContext!) as Server
                    newItem.domain = viewController.serverURLField.text
                    var error2 : NSError? = nil
                    if(viewController.managedObjectContext?.hasChanges == true && viewController.managedObjectContext?.save(&error2) == false) {
                        println("Save did not complete successfully. Error: \(error2?.localizedDescription)")
                        return false
                    }
                    else {
//                        createAlert("Success", message: "You added server to saved list", viewController: viewController)
                        return true
                    }
                }
            } else {
                viewController.errorField.text = "Error: unable to create server instance"
                return false
            }
        } else {
            viewController.errorField.text = "Error: some fields are empty retry"
            return false
        }
    }
    
    class func editServer(viewController :LoginViewController, withDomain domain: String, UsingUsername username : String, AndPassword password : String) -> Bool{
        viewController.errorField.text = ""
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
                    return false
                } else {
                    return true
//                    createAlert("Success", message: "You changed the server settings", viewController: viewController)
                }
            } else {
                viewController.errorField.text = "Error: no server with that name"
                return false
            }
        } else {
            viewController.errorField.text = "Error: Some fields are empty retry"
            return false
        }
    }
    
    class func deleteServer(viewController :LoginViewController, withDomain domain: String) {
        viewController.errorField.text = ""
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
//                    createAlert("Success", message: "You deleted the server", viewController: viewController)
                }
            } else {
                viewController.errorField.text = "Error: no server with that name"
            }
        } else {
            viewController.errorField.text = "Error: server URL is empty"
        }
    }
}
