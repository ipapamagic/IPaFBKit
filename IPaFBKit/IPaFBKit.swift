//
//  IPaFBKit.swift
//  IPaFBKit
//
//  Created by IPa Chen on 2015/7/10.
//  Copyright (c) 2015年 A Magic Studio. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
public class IPaFBKit {
    static public func imageLink(fbID:String,type:String) -> String
    {
        return "http://graph.facebook.com/\(fbID)/picture?type=\(type)"
    }
    static public func postLink(fbID:String) -> String
    {
        return "https://www.facebook.com/photo.php?fbid=\(fbID)"
    }
    static public func imageLink(fbID:String) -> String
    {
        return imageLink(fbID,type:"normal")
    }

    static public func isFBLogin() -> Bool {
        return FBSDKAccessToken.currentAccessToken() != nil
    }

    //MARK: Share
    static public func sharePhoto(image:UIImage, params:[String:AnyObject], complete:((String?) -> ()))
    {
        var mParams = params
        mParams["source"] = UIImageJPEGRepresentation(image, 1);
        let request = FBSDKGraphRequest(graphPath: "/me/photos", parameters: mParams, HTTPMethod: "POST")
        request.startWithCompletionHandler({
            connection,result,error in
            if error != nil {
                complete(nil)
            }
            else {
                if let result = result as? [String:AnyObject] {
                    if let id = result["id"] as? String {
                        complete(id)
                        return
                    }
                }
                complete(nil)
            }
        })
    }
    static public func postOnFeed(name:String?, caption:String?, description:String? , picture:String?, link:String?, complete:((AnyObject, NSError) -> ()))
    {
        var mParams = [String:AnyObject]()
        if let name = name {
            mParams["name"] = name
        }
        if let caption = caption {
            mParams["caption"] = caption
        }
        if let description = description {
            mParams["description"] = description
        }
        if let picture = picture {
            mParams["picture"] = picture
        }
        if let link = link {
            mParams["link"] = link
        }
        let request = FBSDKGraphRequest(graphPath: "/me/feed", parameters: mParams, HTTPMethod: "POST")
        request.startWithCompletionHandler({
            connection,result,error in
            complete(result,error)
        })

    }
}