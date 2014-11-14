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

class SecurityControl: NSObject {
    class func addItem(domain : String, withUsername username : String, usingPassword password: String) -> Bool {
        
        let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .UserPresence, nil)
        
        let query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrService as String : domain,
            kSecAttrAccount as String : username,
            kSecValueData as String : password,
            kSecAttrAccessControl as String : accessControl.takeUnretainedValue()]
        
        SecItemDelete(query as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, nil)
        
        return status == noErr
    }
    
    class func updateItem(domain : String, withUsername username : String, usingPassword password : String) -> Bool {

        let query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrService : domain,
            kSecUseOperationPrompt as String : Constants.updateKeychainPrompt]
        let changes = [
            kSecAttrAccount as String : username,
            kSecValueData as String : password]
        let status: OSStatus = SecItemUpdate(query as CFDictionaryRef, changes as CFDictionaryRef)
        return status == noErr
    }
    
    class func deleteItem(domain : String) -> Bool {
        let query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrService : domain]
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        return status == noErr
        
    }
    
//    class func loadItem(domain : String) -> NSDictionary? {

//    }
    
    class func loadItem(domain : String) -> NSDictionary? {
        let query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrService as String : domain,
            kSecReturnData as String : true,
            kSecMatchLimit as String : kSecMatchLimitOne,
            kSecUseOperationPrompt as String : "Authenticate to retrieve your username/password!"
        ]

        var dataTypeRef :Unmanaged<AnyObject>?

        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        if status == noErr {
            let data = dataTypeRef!.takeRetainedValue() as NSData
            let result = NSKeyedUnarchiver.unarchiveObjectWithData(data) as NSDictionary
            return result
        } else {
            return nil
        }
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
    
    class func evaluateTouch(viewController : webViewController, withDomain domain : String) -> NSDictionary? {
        let context = LAContext()
        var authError : NSError?
        var credentials : NSDictionary?
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:&authError) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics,
                localizedReason: "I need to see if it's really you",
                reply: {(success: Bool, error: NSError!) -> Void in
                    
                    if success {
                        credentials = SecurityControl.loadItem(domain)
                        println(credentials)
                    } else {
                        credentials = nil
                    }
            })
        } else {
            credentials = nil
        }
        return credentials
    }
}
