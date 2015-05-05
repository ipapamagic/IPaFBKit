//
//  IPaFBKit.m
//  IPaFBKit
//
//  Created by IPa Chen on 2014/11/16.
//  Copyright 2014年 A Magic Studio. All rights reserved.
//

#import "IPaFBKit.h"
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

- (void)loginFBWithPublishPermissions:(NSArray*)permissions defaultAudience:(FBSDKDefaultAudience)defaultAudience callback:(void (^)(BOOL))callback
{
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    manager.defaultAudience = defaultAudience;
    [manager logInWithPublishPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                      /* handle success + failure in block */
        if (result.token != nil && !result.isCancelled) {
            callback(YES);
            
        }
        else {
            callback(NO);
        }
    }];
}

- (void)loginFBWithReadPermissions:(NSArray*)permissions callback:(void (^)(BOOL))callback
{
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    [manager logInWithReadPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        /* handle success + failure in block */
        if (result.token != nil && !result.isCancelled) {
            callback(YES);
            
        }
        else {
            callback(NO);
        }
    }];
}

- (BOOL)isFBLogin
{
    return ([FBSDKAccessToken currentAccessToken] != nil);
}
- (void)logoutFB
{
    FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
    [manager logOut];

}
#pragma mark - Share
- (void)sharePhoto:(UIImage*)image params:(NSDictionary*)params callback:(void (^)(NSString*))callbak
{
//    FBRequest *request = [FBRequest requestForUploadPhoto:image];
//    FBRequestConnection *fbConnection = [[FBRequestConnection alloc] init];
//
//    [fbConnection addRequest:request completionHandler:^(FBRequestConnection *connect,id result,NSError* error){
//        if (error) {
//            callbak(nil);
//        }
//        else {
//            callbak(((NSDictionary*)result)[@"id"]);
//       }        
//    }];
//    [fbConnection start];
    NSMutableDictionary *mParams = [@{} mutableCopy];
    mParams[@"source"] = UIImageJPEGRepresentation(image, 1);
//    if (message != nil) {
//        params[@"message"] = message;
//    }
//    if (privacy != nil) {
//        params[@"privacy"] = privacy;
//    }
    for (NSString *key in params.allKeys) {
        mParams[key] = params[key];
    }
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/photos" parameters:mParams HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,id result,NSError *error) {
                              if (error) {
                                  callbak(nil);
                              }
                              else {
                                  callbak(((NSDictionary*)result)[@"id"]);
                              }
                          }];
}
- (void)postOnFeedWithName:(NSString*)name caption:(NSString*)caption description:(NSString*)description picture:(NSString*)picture link:(NSString*)link callback:(void (^)(id, NSError *))callback{
    NSMutableDictionary *params = [@{} mutableCopy];
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
    if (link != nil) {
        params[@"link"] = link;
    }
    // Make the request
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/feed" parameters:params HTTPMethod:@"POST"];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                              callback(result,error);
                          }];
}
//- (void)shareLink:(NSString*)link name:(NSString*)name caption:(NSString*)caption description:(NSString*)description picture:(NSString*)picture callback:(void (^)(BOOL))callback{
//    
//    // NOTE: pre-filling fields associated with Facebook posts,
//    // unless the user manually generated the content earlier in the workflow of your app,
//    // can be against the Platform policies: https://developers.facebook.com/policy
//    
//    // Put together the dialog parameters
//    //    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//    //                                   @"Sharing Tutorial", @"name",
//    //                                   @"Build great social apps and get more installs.", @"caption",
//    //                                   @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
//    //                                   @"https://developers.facebook.com/docs/ios/share/", @"link",
//    //                                   @"http://i.imgur.com/g3Qc1HN.png", @"picture",
//    //                                   nil];
//    void (^doShareLink)() = ^(){
//        FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:[NSURL URLWithString:link]name:name caption:caption
//              description:description              picture:[NSURL URLWithString:picture]];
//        // Make the request
//        if ([FBDialogs canPresentMessageDialogWithParams:params]) {
//            [FBDialogs presentMessageDialogWithParams:params clientState:nil handler:^(FBAppCall *appCall,NSDictionary *result,NSError* error){
//                if (!error) {
//                    // Link posted successfully to Facebook
//                    NSLog(@"result: %@", result);
//                    callback(YES);
//                } else {
//                    // An error occurred, we need to handle the error
//                    // See: https://developers.facebook.com/docs/ios/errors
//                    NSLog(@"%@", error.description);
//                    callback(NO);
//                }
//            }];
//        }
//        else {
//            [self postOnFeedWithName:name caption:caption description:description picture:picture link:link callback:^(id result,NSError* error){
//                callback(error == nil);
//            }];
//        }
//    
//    };
//    [self requestPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone callback:^(BOOL success){
//        if (success) {
//            doShareLink();
//        }
//        else {
//            callback(NO);
//        }
//    }];
//}

- (NSString*)imageLinkWithFBID:(NSString*)fbID
{
    return [self imageLinkWithFBID:fbID type:@"normal"];
}
- (NSString*)imageLinkWithFBID:(NSString *)fbID type:(NSString*)type
{
    return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=%@", fbID,type];
}
@end
