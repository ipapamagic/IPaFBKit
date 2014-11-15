//
//  IPaFBKit.h
//  IPaFBKit
//
//  Created by IPa Chen on 2014/11/16.
//  Copyright 2014年 A Magic Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaFBKit : NSObject {
    
}
+ (id)sharedInstance;
- (BOOL)isFBLogin;
- (void)logoutFB;
- (void)loginFBWithReadPermissions:(NSArray*)permissions callback:(void (^)(BOOL))callback;
- (void)requestPublishPermissions:(NSArray*)permissionsNeeded callback:(void (^)(BOOL))callback;
- (void)shareLink:(NSString*)link name:(NSString*)name caption:(NSString*)caption description:(NSString*)description picture:(NSString*)picture callback:(void (^)(BOOL))callback;
@end
