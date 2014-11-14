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
        
//        let query : [String: AnyObject] = [
//            kSecClass             : kSecClassInternetPassword,
//            kSecAttrServer       : domain,
//            kSecAttrAccount       : username,
//            kSecValueData         : password,
//            kSecAttrAccessible : kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
//        ]
        var query: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, domain, username, password, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly], forKeys: [kSecClass, kSecAttrServer, kSecAttrAccount, kSecValueData, kSecAttrAccessible])
        let dataTypeRef : UnsafeMutablePointer<Unmanaged<AnyObject>?> = nil
        let status: OSStatus = SecItemAdd(query as CFDictionaryRef, dataTypeRef)
        
        println("Status Add: \(dataTypeRef)")
        println(errSecSuccess)
        println(noErr)
        
        return status == errSecSuccess
    }
    
    class func updateItem(domain : String, withUsername username : String, usingPassword password : String) -> Bool {

        let query = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService : domain,
            kSecUseOperationPrompt as String : Constants.updateKeychainPrompt]

        let changes = [
            kSecAttrAccount as String : username,
            kSecValueData as String : password]
        
        let status: OSStatus = SecItemUpdate(query as CFDictionaryRef, changes as CFDictionaryRef)
        
        println("Status Update: \(status)")
        
        return status == noErr
    }
    
    class func deleteItem(domain : String) -> Bool {
        let query = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService : domain]
        let status: OSStatus = SecItemDelete(query as CFDictionaryRef)
        println("Status Add: \(status)")
        return status == noErr
        
    }
    
//    class func loadItem(domain : String) -> NSDictionary? {

//    }
    
    class func loadItem(domain : String) -> NSDictionary? {
        let query = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : domain,
            kSecReturnAttributes as String : true,
            kSecMatchLimit as String : kSecMatchLimitOne,
            kSecUseOperationPrompt as String : "Authenticate to retrieve your username/password!"
        ]

        var dataTypeRef :Unmanaged<AnyObject>?
        let status: OSStatus = SecItemCopyMatching(query, &dataTypeRef)
        let opaque = dataTypeRef?.toOpaque()
        var credentials: NSDictionary?
        println("Status load: \(status)")
        if status == noErr {
            println("HERE")
            let data = Unmanaged<NSData>.fromOpaque(opaque!).takeUnretainedValue() as NSData
            
            // Convert the data retrieved from the keychain into a string
            credentials = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary
        }
        return credentials
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
                        println("Credentials: \(credentials)")
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
