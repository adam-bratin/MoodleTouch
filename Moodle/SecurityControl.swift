//
//  SecurityControl.swift
//  Moodle
//
//  Created by Adam Bratin on 11/12/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import Security
import LocalAuthentication
import Foundation

class SecurityControl: NSObject {
    class func addItem(domain : String, withUsername username : String, usingPassword password: String) -> Bool {
        
        var data: NSData? = password.dataUsingEncoding(NSUTF8StringEncoding)
        var query = NSMutableDictionary()
        query[kSecClass as String] = kSecClassInternetPassword
        query[kSecAttrServer as String] = domain
        query[kSecAttrAccount as String] = username
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        var status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)
        return status == errSecSuccess
    }
    
    class func updateItem(domain : String, withUsername username : String, usingPassword password : String) -> Bool {

        var query = NSMutableDictionary()
        query[kSecClass as String] = kSecClassInternetPassword
        query[kSecAttrServer as String] = domain
        query[kSecUseOperationPrompt as String] = Constants.updateKeychainPrompt

        var changes = NSMutableDictionary()
        changes[kSecAttrAccount as String] = username
        changes[kSecValueData as String] = password
        
        var status: OSStatus = SecItemUpdate(query as CFDictionaryRef, changes as CFDictionaryRef)
        
        return status == noErr
    }
    
    class func deleteItem(domain : String) -> Bool {
        var query = NSMutableDictionary()
        query[kSecClass as String] = kSecClassInternetPassword
        query[kSecAttrServer as String] = domain
        var status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        return status == noErr
        
    }
    
    class func loadItem(domain : String) -> (Dictionary<String,String>) {
        var query = NSMutableDictionary()
        query[kSecClass as String] = kSecClassInternetPassword
        query[kSecAttrServer as String] = domain
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var dataTypeRef : Unmanaged<AnyObject>?
        var status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        var opaque = dataTypeRef?.toOpaque()
        var credentials: NSDictionary?
        if let opaque = opaque {
            var data = Unmanaged<NSDictionary>.fromOpaque(opaque).takeUnretainedValue()
            // Convert the data retrieved from the keychain into a string
            credentials = NSDictionary(dictionary: data)
        }
        
        var query2 = NSMutableDictionary()
        query2[kSecClass as String] = kSecClassInternetPassword
        query2[kSecAttrServer as String] = domain
        query2[kSecReturnData as String] = true
        query2[kSecMatchLimit as String] = kSecMatchLimitOne
        var dataTypeRef2 : Unmanaged<AnyObject>?
        var status2: OSStatus = SecItemCopyMatching(query2, &dataTypeRef2)
        var opaque2 = dataTypeRef2?.toOpaque()
        var password : NSString?
        if let opaque2 = opaque2 {
            var data = Unmanaged<NSData>.fromOpaque(opaque2).takeUnretainedValue()
            // Convert the data retrieved from the keychain into a string
            password = NSString(data: data, encoding: NSUTF8StringEncoding)
            
        }
        var result : Dictionary<String, String>
        if let creds = credentials {
            if let pswd = password  {
                result = ["username" : creds["acct"] as String, "password" : pswd as String]
            } else {
                result = Dictionary<String, String>()
            }
        } else {
            result = Dictionary<String, String>()
        }
        return result
    }
    
    class func resetKeychain() -> Bool {
        return deleteAllKeysForSecClass(kSecClassGenericPassword) &&
            self.deleteAllKeysForSecClass(kSecClassInternetPassword) &&
            self.deleteAllKeysForSecClass(kSecClassCertificate) &&
            self.deleteAllKeysForSecClass(kSecClassKey) &&
            self.deleteAllKeysForSecClass(kSecClassIdentity)
    }
    
    private class func deleteAllKeysForSecClass(secClass: CFTypeRef) -> Bool {
        var keychainQuery = NSMutableDictionary()
        keychainQuery[kSecClass as String] = secClass
        
        var result:OSStatus = SecItemDelete(keychainQuery)
        if (result == errSecSuccess) {
            return true
        } else {
            return false
        }
    }
    
    class func evaluateTouch(viewController : webViewController, withDomain domain : String) {
//        var credentials : Dictionary<String,String>
        
        viewController.startTouchID = true
        let touchIDContext = LAContext()
        var touchIDError : NSError?
        var reasonString = "I need to see if it's really you"
        if (touchIDContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &touchIDError)) {
            touchIDContext .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                if success {
                    viewController.creds = SecurityControl.loadItem(domain)
                    viewController.createLoginScript()
                } else {
                    viewController.creds = Dictionary<String, String>()
                    println(evalPolicyError?)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        println("Authentication was cancelled by the system")
                        println("Cancel")
                        viewController.navigationController?.popViewControllerAnimated(true)
                        return
                        
                    case LAError.UserCancel.rawValue:
                        println("Authentication was cancelled by the user")
                        println("cancel")
                        viewController.navigationController?.popViewControllerAnimated(true)
                        return
                        
//                    case LAError.UserFallback.rawValue:
//                        println("User selected to enter custom password")
//                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
//                            SecurityControl.showPasswordAlert(viewController)
//                        })
                        
                    default:
                        println("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            SecurityControl.showPasswordAlert(viewController)
                        })
                    }
                    viewController.createLoginScript()
                }
            })
        } else {
            viewController.creds = Dictionary<String, String>()
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch touchIDError!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                println("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                println("A passcode has not been set")
                
            default:
                // The LAError.TouchIDNotAvailable case.
                println("TouchID not available")
            }
            
            // Optionally the error description can be displayed on the console.
            println(touchIDError?.localizedDescription)
            
            // Show the custom alert view to allow users to enter the password.
            SecurityControl.showPasswordAlert(viewController)
            
            viewController.createLoginScript()
        }
    }
    
    class func showPasswordAlert(viewController : webViewController) {
        var passwordAlert : UIAlertView = UIAlertView(title: "TouchIDDemo", message: "Please type your password", delegate: viewController, cancelButtonTitle: "Cancel", otherButtonTitles: "Okay")
        passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
        passwordAlert.show()
    }
}
