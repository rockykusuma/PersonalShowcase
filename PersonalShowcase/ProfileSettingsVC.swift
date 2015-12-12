//
//  ProfileSettingsVC.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 10/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class ProfileSettingsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var displayName : MaterialTextField!
    @IBOutlet weak var birthDay : MaterialTextField!
    @IBOutlet weak var aboutYourself : UITextView!
    @IBOutlet weak var profileImageSelector: UIImageView!
    var profileImagePicker : UIImagePickerController!
    var profileImageSelected = false
    var UserRef : Firebase!
    var request : Request?
    var picker : UIDatePicker!
    var pickerIsOn : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImagePicker = UIImagePickerController()
        profileImagePicker.delegate = self
        profileImageSelector.layer.cornerRadius = profileImageSelector.frame.size.width/2
        profileImageSelector.clipsToBounds = true
        getProfileDetails()

    }
    
    func getProfileDetails() {
        
        //let profileDetails = DataService.instance.REF_USER_CURRENT.childByAppendingPath("displayName") as String?
//        DataService.instance.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
//            //pint(snapshot.value)
//            
//            //self.posts = []
//            if let snapshots = snapshot.value as? Dictionary<String,String> {
//                    print("SnapShot:---> \(snapshots)")
//                
//                        //let displayName = snapshots.
//                        //let post = Post(postkey: key, dictionary: postDict)
//                        //self.posts.append(post)
//                
//
//            }
//           
//        })
        
        DataService.instance.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
            // do some stuff once
            if let userSnapShot = snapshot.value as? Dictionary<String,AnyObject> {
                
                if let displayName = userSnapShot["displayName"] as? String{
                    self.displayName.text = displayName
                }
                if let birthday = userSnapShot["birthday"] as? String{
                    self.birthDay.text = birthday
                }
                if let aboutYourself = userSnapShot["aboutUser"] as? String{
                    self.aboutYourself.text = aboutYourself
                }
                if let imageURL = userSnapShot["profileImageURL"] as? String{
                    //self.profileImageSelector.image
                    if imageURL != "" {
                        self.request = Alamofire.request(.GET,imageURL).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                            
                            if err == nil {
                                let img = UIImage(data: data!)!
                                self.profileImageSelector.image = img
                               // FeedVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                            } else {
                                print(err.debugDescription)
                            }
                        })

                    }
                }
            }
//            if let height = snapshot.value["displayName"] as? String {
//                self.displayName.text = height
//                print("\(snapshot.key) was \(height)")
//            }
           
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImagePicker.dismissViewControllerAnimated(true, completion: nil)
        profileImageSelector.image = image
        profileImageSelected = true
    }
    @IBAction func selectProfileImageBtn(sender: UITapGestureRecognizer) {
        presentViewController(profileImagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func selectDateFromDatePicker(sender:UITapGestureRecognizer){
        
        if !(pickerIsOn){
        
        picker = UIDatePicker()
        picker.datePickerMode = UIDatePickerMode.Date
        picker.addTarget(self, action: "dueDateChanged:", forControlEvents: UIControlEvents.ValueChanged)
        picker.frame = CGRectMake(0, self.view.frame.size.height-150, self.view.frame.size.width, 200)
        picker.backgroundColor = DataService.instance.colorWithHexString("2DC077")
        //you probably don't want to set background color as black
        self.view.addSubview(picker)
            pickerIsOn = true
        }else{
            picker.removeFromSuperview()
            pickerIsOn = false
            // To resign the inputView on clicking done.

        }
        
    }
    func dueDateChanged(sender:UIDatePicker){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.birthDay.text = dateFormatter.stringFromDate(picker.date)
    }
    

    
    @IBAction func profilePageDoneBtnClicked(sender:UIButton) {
        if let displayNameStr = displayName.text where displayNameStr != "", let birthdayStr = birthDay.text where birthdayStr != "",let aboutYourselfStr = aboutYourself.text where aboutYourselfStr != "" {
            if let profileImageTemp = profileImageSelector.image where profileImageSelected == true{
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(profileImageTemp, 0.2)!
                let keyData = "3OZXNDM149b61b3c46c508206ab4f2d3a78d6280".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJson = "json".dataUsingEncoding(NSUTF8StringEncoding)!
               
                
                Alamofire.upload(.POST, url, multipartFormData: { (mutiPartFormData:MultipartFormData) -> Void in
                    mutiPartFormData.appendBodyPart(data: imgData, name: "fileupload",fileName: "image",mimeType: "image.jpg")
                    mutiPartFormData.appendBodyPart(data: keyData, name: "key")
                    mutiPartFormData.appendBodyPart(data: keyJson, name: "format")
                    
                    }, encodingCompletion: { (encodingResult:Manager.MultipartFormDataEncodingResult) -> Void in
                        
                        switch encodingResult {
                            
                        case.Success(let upload,_,_):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary<String,AnyObject> {
                                    if let links = info["links"] as? Dictionary<String,AnyObject> {
                                        if let imageLink = links["image_link"] as? String {
                                            //print("Link: --->>>> \(imageLink)")
                                            self.userDetailsToFirebase(imageLink)
                                           // let alert = DataService.instance.showErrorAlert("Success", msg: "Your Post has Been Successfully Posted!!")
                                           // self.presentViewController(alert, animated: true, completion: nil)
                                            
                                        }
                                    }
                                }
                            })
                        case.Failure(let error):
                            print(error)
                        }
                })
            } else {
                self.userDetailsToFirebase(nil)
            }
            let alert2 = UIAlertController(title: "Success", message: "Your Crediantials are Succesfully Stored.", preferredStyle: .Alert)
            let action2 = UIAlertAction(title: "OK", style: .Default, handler: { (action2) -> Void in
                self.performSegueWithIdentifier("firstTimeLoginFinished", sender: nil)
            })
            alert2.addAction(action2)
            self.presentViewController(alert2, animated: true, completion:nil)
            
            
        } else {
            let alert = DataService.instance.showErrorAlertSimple("Error", msg: "Please fill all the Details")
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func userDetailsToFirebase(imageUrl:String?) {
        let firebaseUSerDetails_displayName = DataService.instance.REF_USER_CURRENT.childByAppendingPath("displayName")
        firebaseUSerDetails_displayName.setValue(displayName.text!)
        
        let firebaseUSerDetails_birthday = DataService.instance.REF_USER_CURRENT.childByAppendingPath("birthday")
        firebaseUSerDetails_birthday.setValue(birthDay.text!)
        
        let firebaseUSerDetails_aboutUser = DataService.instance.REF_USER_CURRENT.childByAppendingPath("aboutUser")
        firebaseUSerDetails_aboutUser.setValue(aboutYourself.text!)
        if imageUrl != nil {
            let firebaseUSerDetails_profileImageURL = DataService.instance.REF_USER_CURRENT.childByAppendingPath("profileImageURL")
            firebaseUSerDetails_profileImageURL.setValue(imageUrl)
        }

    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
