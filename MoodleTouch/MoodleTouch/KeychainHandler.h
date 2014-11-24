//
//  KeychainHandler.h
//  MoodleTouch
//
//  Created by Adam Bratin on 11/20/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSSStatusReturnDelegate;
@protocol KeychainResultReturnDelegate;

@interface KeychainHandler : NSObject
@property (nonatomic, weak) id<OSSStatusReturnDelegate> OSSStatusDelegate;
@property (nonatomic, weak) id<KeychainResultReturnDelegate> ResultsDelegate;

-(void)copyMatchingAsync:(NSString*)domain;
-(void)addItemAsync:(NSString*)domain withUsername:(NSString*)username andPassword:(NSString*)password;
-(void)updateItemAsync:(NSString*)domain withUsername:(NSString*)username andPassword:(NSString*)password;
-(void)deleteItemAsync:(NSString*)domain;
@end


@protocol OSSStatusReturnDelegate <NSObject>
@required
-(void)reutrnOSStatus:(NSDictionary*)results;
@end

@protocol KeychainResultReturnDelegate <NSObject>
@required
-(void)returnKeychainResults:(NSDictionary*)results;
-(void)authenticationFailed;
@end