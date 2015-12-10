//
//  DataService.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 09/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import Foundation
import Firebase

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
    
    func showErrorAlert(title: String, msg: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        return alert
    }

    
}