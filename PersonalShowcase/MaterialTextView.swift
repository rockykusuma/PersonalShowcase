//
//  MaterialTextView.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 10/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import UIKit

class MaterialTextView: UITextView {


    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        layer.cornerRadius = 2.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1.0
        layer.masksToBounds = true
        // Drawing code
    }
    

    
    // For Editable Text


}
