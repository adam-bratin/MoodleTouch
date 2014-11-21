//
//  KeychainHandler.m
//  MoodleTouch
//
//  Created by Adam Bratin on 11/20/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

#import "KeychainHandler.h"
@import Security;

@implementation KeychainHandler

-(void)copyMatchingAsync:(NSString*)domain{
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: domain,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecReturnAttributes: @YES,
        (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitOne,
        (__bridge id)kSecUseOperationPrompt: @"Authenticate to retrieve your password"};
        CFTypeRef dataTypeRef = NULL;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &dataTypeRef);
        NSDictionary *results = (__bridge NSDictionary*)dataTypeRef;
        if(self.ResultsDelegate!=nil) {
            [self.ResultsDelegate returnKeychainResults:results];
        }
    });
}

-(void)addItemAsync:(NSString*)domain withUsername:(NSString*)username andPassword:(NSString*)password {
    CFErrorRef error = NULL;
    SecAccessControlRef sacObject;
    //kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                kSecAttrAccessibleWhenUnlocked,
                                                kSecAccessControlUserPresence, &error);
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: domain,
        (__bridge id)kSecAttrAccount: username,
        (__bridge id)kSecValueData: [password dataUsingEncoding:NSUTF8StringEncoding],
//        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly,
        (__bridge id)kSecUseNoAuthenticationUI: @YES,
        (__bridge id)kSecAttrAccessControl: (__bridge_transfer id)sacObject};
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status =  SecItemAdd((__bridge CFDictionaryRef)query, nil);
        NSLog(@"Add: %d",(int)status);
        NSDictionary *results = @{
            @"type": @"add",
            @"status": [[NSNumber alloc] initWithInt:status]};
        NSLog(@"Results: %@", results);
        NSLog(@"Self: %@", self.OSSStatusDelegate);
        
        if(self.OSSStatusDelegate!=nil) {
            [self.OSSStatusDelegate reutrnOSStatus:results];
        }
    });
}

-(void)updateItemAsync:(NSString*)domain withUsername:(NSString*)username andPassword:(NSString*)password{
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: domain,
        (__bridge id)kSecUseOperationPrompt: @"Authenticate to update your password"};
    
    NSDictionary *changes = @{
        (__bridge id)kSecAttrAccount: username,
        (__bridge id)kSecValueData: [password dataUsingEncoding:NSUTF8StringEncoding]};
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status =  SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)changes);
        NSLog(@"Update: %d",(int)status);
        NSDictionary *results = @{
                                  @"type": @"update",
                                  @"status": [[NSNumber alloc] initWithInt:status]};
        if(self.OSSStatusDelegate!=nil) {
            [self.OSSStatusDelegate reutrnOSStatus:results];
        }
    });
}

-(void)deleteItemAsync:(NSString*)domain {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: domain};
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status =  SecItemDelete((__bridge CFDictionaryRef)query);
        NSLog(@"Delete: %d",(int)status);
        NSDictionary *results = @{
                                  @"type": @"delete",
                                  @"status": [[NSNumber alloc] initWithInt:status]};
        if(self.OSSStatusDelegate!=nil) {
            [self.OSSStatusDelegate reutrnOSStatus:results];
        }
    });
}

@end
