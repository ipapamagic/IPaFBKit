//
//  IPaFBKit.h
//  IPaFBKit
//
//  Created by IPa Chen on 2014/11/16.
//  Copyright 2014年 A Magic Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import UIKit;
@interface IPaFBKit : NSObject {
    
}
+ (id)sharedInstance;
- (BOOL)isFBLogin;
- (void)logoutFB;

- (void)loginFBWithPublishPermissions:(NSArray*)permissions defaultAudience:(FBSDKDefaultAudience)defaultAudience callback:(void (^)(BOOL))callback;
- (void)loginFBWithReadPermissions:(NSArray*)permissions callback:(void (^)(BOOL))callback;

//- (void)shareLink:(NSString*)link name:(NSString*)name caption:(NSString*)caption description:(NSString*)description picture:(NSString*)picture callback:(void (^)(BOOL))callback;
- (void)sharePhoto:(UIImage*)image params:(NSDictionary*)params callback:(void (^)(NSString*))callbak;
- (void)postOnFeedWithName:(NSString*)name caption:(NSString*)caption description:(NSString*)description picture:(NSString*)picture link:(NSString*)link callback:(void (^)(id, NSError *))callback;
//get facebook user image link
- (NSString*)imageLinkWithFBID:(NSString*)fbID;
- (NSString*)imageLinkWithFBID:(NSString *)fbID type:(NSString*)type;
@end
