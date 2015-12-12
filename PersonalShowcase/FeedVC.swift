//
//  FeedVC.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 09/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class FeedVC: UIViewController , UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImg: UIImageView!
    var refreshControl : UIRefreshControl!
    
    var imagePicker : UIImagePickerController!
    var posts = [Post]()
    var imageSelected = false
    static var imageCache = NSCache()
    
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        self.refreshControl.beginRefreshing()
        self.getFeeds()
        self.refreshControl.endRefreshing()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 356
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.refreshControl = UIRefreshControl()
        self.refreshControl.enabled = true
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        getFeeds()

        

    }
    func getFeeds() {
        DataService.instance.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            //pint(snapshot.value)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    //print("Snap:---> \(snap)")
                    if let postDict = snap.value as? Dictionary<String,AnyObject> {
                        let key = snap.key
                        let post = Post(postkey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileSettings(sender:AnyObject){
        
        self.performSegueWithIdentifier("profileSettingsSegue", sender: nil)
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.request?.cancel()
            var img : UIImage?
            if let url = post.imageURL {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
                
            }
            cell.configureCell(post,image: img)
            return cell
        } else {
            return PostCell()
        }
        
    
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageURL == nil {
            return 150
        }else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImg.image = image
        imageSelected = true
        
    }

    @IBAction func selectImageBtn(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func makePostBtnClicked(sender: AnyObject) {
        if let text = postField.text where text != "" {
            if let imageTemp = imageSelectorImg.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(imageTemp, 0.2)!
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
                                            self.postToFirebase(imageLink)
                                            let alert = DataService.instance.showErrorAlertSimple("Success", msg: "Your Post has Been Successfully Posted!!")
                                            self.presentViewController(alert, animated: true, completion: nil)
                                            
                                        }
                                    }
                                }
                            })
                        case.Failure(let error):
                            print(error)
                        }
                })
            } else {
                self.postToFirebase(nil)
            }
        }
        //let alert = DataService.instance.showErrorAlert("Success", msg: "Your Post has Been Successfully Posted!!")
        //self.presentViewController(alert, animated: true, completion: nil)

    }
    
    
    
    func postToFirebase(imageUrl:String?) {
        //let firebaseUSerDetails_username = DataService.instance.REF_USER_CURRENT
        let firebaseUSerDetails_uniqueUserName = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        //print("Current User Name is --------->\(firebaseUSerDetails_username)")
        var post : Dictionary <String, AnyObject> = [
            "description" : postField.text!,
            "likes" : 0,
            "uniqueUserName" : firebaseUSerDetails_uniqueUserName
        ]
        if imageUrl != nil {
            post["imageURL"] = imageUrl!
        }

        let firebasePost = DataService.instance.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        postField.text = ""
        imageSelectorImg.image = UIImage(named: "SLR Camera Filled-100")
        imageSelected = false
        tableView.reloadData()
    }
    
    
}
