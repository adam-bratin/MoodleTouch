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
        
        println(errSecSuccess)
        println(noErr)
        
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
        println("Status Add: \(status)")
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
        let opaque = dataTypeRef?.toOpaque()
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
        
        let result:OSStatus = SecItemDelete(keychainQuery)
        if (result == errSecSuccess) {
            return true
        } else {
            return false
        }
    }
    
    class func evaluateTouch(viewController : webViewController, withDomain domain : String) {
//        var credentials : Dictionary<String,String>
        var touchIDContext = LAContext()
        var touchIDError : NSError?
        var reasonString = "I need to see if it's really you"
        if (touchIDContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:&touchIDError)) {
            touchIDContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                        viewController.creds = SecurityControl.loadItem(domain)
                } else {
                    viewController.creds = Dictionary<String, String>()
                }
            })
        } else {
            viewController.creds = Dictionary<String, String>()
        }
        viewController.loadPage()
    }
}
