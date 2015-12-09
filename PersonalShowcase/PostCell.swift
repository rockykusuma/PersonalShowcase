//
//  PostCell.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 09/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import UIKit
import Alamofire


class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage : UIImageView!
    @IBOutlet weak var showCaseImg : UIImageView!
    @IBOutlet weak var descriptionText : UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    var post : Post!
    var request : Request?    // Firebase Object
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(post:Post,image:UIImage?) {
        self.post = post
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
                    }
                })
            }
            
        }else {
            self.showCaseImg.hidden = true
        }
        
    }
    
    
    
}
