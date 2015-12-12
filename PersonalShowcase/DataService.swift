//
//  DataService.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 09/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import Foundation
import Firebase
import UIKit

let URL_BASE = "https://personalshowcase.firebaseio.com"

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_LIKES = Firebase(url: "\(URL_BASE)/likes")
    
    
    var REF_BASE : Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS : Firebase {
        return _REF_POSTS
    }

    var REF_USERS : Firebase {
        return _REF_USERS
    }
    
    var REF_LIKES : Firebase {
        return _REF_LIKES
    }
    
    var REF_USER_CURRENT : Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }

    func createFirebaseUser (uid:String, user:Dictionary<String,String>) {
        
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    
    
    
    func showErrorAlertSimple(title: String, msg: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
      
        
        alert.addAction(action)
        return alert
   
    }
    
    
    // Color Instantiation with Hash Code
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
}