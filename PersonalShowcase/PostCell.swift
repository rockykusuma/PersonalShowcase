//
//  PostCell.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 09/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage : UIImageView!
    @IBOutlet weak var showCaseImg : UIImageView!
    @IBOutlet weak var descriptionText : UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage : UIImageView!
    var post : Post!
    var request : Request?
    var likeRef : Firebase!   // Firebase Object
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        // Initialization code
    }

    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
    }


    func configureCell(post:Post,image:UIImage?) {
        self.post = post
        likeRef = DataService.instance.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageURL != nil {
            if image != nil {
                self.showCaseImg.image = image
            }else {
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showCaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                    } else {
                        print(err.debugDescription)
                    }
                })
            }
            
        }else {
            self.showCaseImg.hidden = true
        }
       // likeRef.observeSingleEventOfType(<#T##eventType: FEventType##FEventType#>, withBlock: <#T##((FDataSnapshot!) -> Void)!##((FDataSnapshot!) -> Void)!##(FDataSnapshot!) -> Void#>)
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapShot in
            
            /// IN firebase if there is no data in .value, you will get as NSNULL
            if let _ = snapShot.value as? NSNull {
                // This is means we have not liked this specified post
                self.likeImage.image = UIImage(named: "heart-empty")

            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
            
        })

    }
    
    func likeTapped(sender: UITapGestureRecognizer){
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapShot in
            
            
            /// IN firebase if there is no data in .value, you will get as NSNULL
            if let _ = snapShot.value as? NSNull {
                // This is means we have not liked this specified post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLike(true)
                self.likeRef.setValue(true)
            } else {
               self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLike(false)
                self.likeRef.removeValue()
            }
            
        })
   
    }
  
}
