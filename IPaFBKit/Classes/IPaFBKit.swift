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
open class IPaFBKit:NSObject {
    @objc static open func imageLink(_ fbID:String,type:String) -> String
    {
        return "http://graph.facebook.com/\(fbID)/picture?type=\(type)"
    }
    @objc static open func postLink(_ fbID:String) -> String
    {
        return "https://www.facebook.com/photo.php?fbid=\(fbID)"
    }
    @objc static open func imageLink(_ fbID:String) -> String
    {
        return imageLink(fbID,type:"normal")
    }

    @objc static open func isFBLogin() -> Bool {
        return FBSDKAccessToken.current() != nil
    }
    
    @objc static open func checkPermissions(_ permission:String) -> Bool {
        return FBSDKAccessToken.current().hasGranted(permission)
    }
    //MARK: Share
    @objc static open func sharePhoto(_ image:UIImage,quality:CGFloat, params:[String:Any], complete:@escaping ((String?) -> ()))
    {
        var mParams = params
        mParams["source"] = image.jpegData(compressionQuality:quality) as AnyObject?
        let request = FBSDKGraphRequest(graphPath: "/me/photos", parameters: mParams, httpMethod: "POST")!
        
        _ = request.start(completionHandler: {
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
    @objc static open func postOnFeed(_ name:String?, caption:String?, description:String? , picture:String?, link:String?, complete:@escaping ((AnyObject, Error?) -> ()))
    {
        var mParams = [String:AnyObject]()
        if let name = name {
            mParams["name"] = name as AnyObject?
        }
        if let caption = caption {
            mParams["caption"] = caption as AnyObject?
        }
        if let description = description {
            mParams["description"] = description as AnyObject?
        }
        if let picture = picture {
            mParams["picture"] = picture as AnyObject?
        }
        if let link = link {
            mParams["link"] = link as AnyObject?
        }
        let request = FBSDKGraphRequest(graphPath: "/me/feed", parameters: mParams, httpMethod: "POST")!
        request.start(completionHandler: {
            connection,result,error in
            complete(result as AnyObject,error)
        })
//        request.start(completionHandler: {
//            connection,result,error in
//            complete(result,error)
//        })

    }
    
    @objc static open func me(_ fields:[String],complete:@escaping (Any?,Error?)->()) {
        let fieldsString = fields.joined(separator: ",")
        let parameters = ["fields":fieldsString]
        let request = FBSDKGraphRequest(graphPath:"me",parameters:parameters)
        _ = request?.start(completionHandler: { connection, user, error in
            complete(user,error)
        })
    }
  
    
}
