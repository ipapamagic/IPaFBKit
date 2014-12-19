//
//  IPaFBKit.m
//  IPaFBKit
//
//  Created by IPa Chen on 2014/11/16.
//  Copyright 2014年 A Magic Studio. All rights reserved.
//

#import "IPaFBKit.h"
#import <FacebookSDK/FacebookSDK.h>
@interface IPaFBKit()
@end
@implementation IPaFBKit
static IPaFBKit *instance;
+ (id)allocWithZone:(NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }

    });
    return instance;
}
+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil){
            instance = [[IPaFBKit alloc] init];
        }
    });
    
    return instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
-(id)init
{
    self = [super init];
    
    return self;
}
- (void)loginFBInBackgroundWithReadPermissions:(NSArray*)permissions
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          
                                      }];
        
    }
}
- (void)loginFBWithReadPermissions:(NSArray*)permissions callback:(void (^)(BOOL))callback
{
    if ([FBSession activeSession].isOpen) {
        //already login
        if (([FBSession activeSession].state & FBSessionStateCreatedTokenLoaded) == FBSessionStateCreatedTokenLoaded) {
            
            callback(YES);
            return ;
        }
        else {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
    }
    
    BOOL hasCacheFBToken = ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded);
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:!hasCacheFBToken
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      /* handle success + failure in block */
                                      switch (status) {
                                          case FBSessionStateOpen:
                                              callback(YES);
                                              break;
                                              
                                          case FBSessionStateClosed:
                                              break;
                                          case FBSessionStateClosedLoginFailed:
                                              callback(NO);
                                              break;
                                          default:
                                              break;
                                      }
                                      
                                  }];
}
- (void)requestPublishPermissions:(NSArray*)permissionsNeeded callback:(void (^)(BOOL))callback
{
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSArray *permissionList = (NSArray *)[result data];
                                  NSMutableDictionary *currentPermissions = [@{} mutableCopy];
                                  for (NSDictionary *permission in permissionList) {
                                      currentPermissions[permission[@"permission"]] = permission[@"status"];
                                  }
                                  
                                  
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      NSString *status = [currentPermissions objectForKey:permission];
                                      if (![status isEqualToString:@"granted"]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              if (!error) {
                                                                                  // Permission granted, we can request the user information
                                                                                  callback(YES);
                                                                              } else {
                                                                                  // An error occurred, handle the error
                                                                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                                  NSLog(@"%@", error.description);
                                                                                  callback(NO);
                                                                            }
                                                                          }];
                                  } else {
                                      // Permissions are present, we can request the user information
                                      callback(YES);
                                  }
                                  
                              } else {
                                  // There was an error requesting the permission information
                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"%@", error.description);
                                  callback(NO);
                              }
                          }];

}
- (BOOL)isFBLogin
{
    if ([FBSession activeSession].isOpen) {
        return YES;
    }
    
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        return [FBSession openActiveSessionWithAllowLoginUI:NO];
    }
    return NO;
}
- (void)logoutFB
{
    [[FBSession activeSession] closeAndClearTokenInformation];
}
#pragma mark - Share
- (void)shareLink:(NSString*)link name:(NSString*)name caption:(NSString*)caption description:(NSString*)description picture:(NSString*)picture callback:(void (^)(BOOL))callback{
    
    // NOTE: pre-filling fields associated with Facebook posts,
    // unless the user manually generated the content earlier in the workflow of your app,
    // can be against the Platform policies: https://developers.facebook.com/policy
    
    // Put together the dialog parameters
    //    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                   @"Sharing Tutorial", @"name",
    //                                   @"Build great social apps and get more installs.", @"caption",
    //                                   @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
    //                                   @"https://developers.facebook.com/docs/ios/share/", @"link",
    //                                   @"http://i.imgur.com/g3Qc1HN.png", @"picture",
    //                                   nil];
    void (^doShareLink)() = ^(){
        
        FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:[NSURL URLWithString:link]name:name caption:caption
              description:description              picture:[NSURL URLWithString:picture]];
        // Make the request
        if ([FBDialogs canPresentMessageDialogWithParams:params]) {
            [FBDialogs presentMessageDialogWithParams:params clientState:nil handler:^(FBAppCall *appCall,NSDictionary *result,NSError* error){
                if (!error) {
                    // Link posted successfully to Facebook
                    NSLog(@"result: %@", result);
                    callback(YES);
                } else {
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors
                    NSLog(@"%@", error.description);
                    callback(NO);
                }
            }];
        }
        else {
            NSMutableDictionary *params = [@{@"link":link} mutableCopy];
            if (name != nil) {
                params[@"name"] = name;
            }
            if (caption != nil) {
                params[@"caption"] = caption;
            }
            if (description != nil) {
                params[@"description"] = description;
            }
            if (picture != nil) {
                params[@"picture"] = picture;
            }
            
            // Make the request
            [FBRequestConnection startWithGraphPath:@"/me/feed"
                                         parameters:params
                                         HTTPMethod:@"POST"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          // Link posted successfully to Facebook
                                          NSLog(@"result: %@", result);
                                          callback(YES);
                                      } else {
                                          // An error occurred, we need to handle the error
                                          // See: https://developers.facebook.com/docs/ios/errors
                                          NSLog(@"%@", error.description);
                                          callback(NO);
                                      }
                                  }];
        }
    
    };
    [self requestPublishPermissions:@[@"publish_actions"] callback:^(BOOL success){
        if (success) {
            doShareLink();
        }
        else {
            callback(NO);
        }
    }];
}

- (NSString*)imageLinkWithFBID:(NSString*)fbID
{
    return [self imageLinkWithFBID:fbID type:@"normal"];
}
- (NSString*)imageLinkWithFBID:(NSString *)fbID type:(NSString*)type
{
    return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=%@", fbID,type];
}
@end
