//
//  Post.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 09/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import Foundation
import Firebase
class Post {
    
    private var _postDescription : String!
    private var _imageURL : String?
    private var _likes : Int!
    private var _username : String!
    private var _postKey : String!
    private var _postRef : Firebase!
    
    
    var postKey : String {
        return _postKey
    }
    
    
    var postDescription : String {
        return _postDescription
    }
    
    var imageURL : String? {
        return _imageURL
    }
    
    var likes : Int {
        return _likes
    }
    
    var username : String {
        return _username
    }
    
    
    

    init(description : String, imageURL : String? , username : String) {
        self._postDescription = description
        self._imageURL = imageURL
        self._username = username
        
    }
    
    init(postkey : String , dictionary : Dictionary <String, AnyObject >) {
        
        
        self._postKey = postkey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        if let imageURL = dictionary["imageURL"] as? String {
            self._imageURL = imageURL
        }
        if let description = dictionary["description"] as? String {
            self._postDescription = description
        }
        
        self._postRef = DataService.instance.REF_POSTS.childByAppendingPath(self._postKey)
        
   
    }
    

    func adjustLike(addLike:Bool) {
        
        if addLike == true {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.childByAppendingPath("likes").setValue(_likes)
    }
    
    
    
    
    
}