//
//  ViewController.swift
//  PersonalShowcase
//
//  Created by Rakesh Kusuma on 08/12/15.
//  Copyright © 2015 Attic Infomatics. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import MBProgressHUD
class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil{
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fbBtnPressed(sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: nil) { (facebookResult:FBSDKLoginManagerLoginResult!, facebookError:NSError!) -> Void in
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Authenticating..."
            
            if facebookError != nil {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let alert = DataService.instance.showErrorAlertSimple("Could Not Login", msg: "Facebook Login Failed")
                self.presentViewController(alert, animated: true, completion: nil)
                print("Facebook Login Failed. Error \(facebookError)")
                
            }else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Succesfully logged in to Facebook with Access Token : \(accessToken)")
                
                DataService.instance.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, fAuthData) -> Void in
                    if error != nil {
                        let alert = DataService.instance.showErrorAlertSimple("Could Not Login", msg: "Login Failed")
                        self.presentViewController(alert, animated: true, completion: nil)
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(fAuthData)")
                        var gender:String?
                        var name:String?
                        var email:String?
                        if let cachedUserProfile = (fAuthData.providerData["cachedUserProfile"]) as? Dictionary<String,AnyObject> {
                            gender = self.stringFormatting("\(cachedUserProfile["gender"])")
                            name = self.stringFormatting("\(cachedUserProfile["name"])")
                            email = self.stringFormatting("\(cachedUserProfile["email"])")
                        }
                        let profileImage = self.stringFormatting("\(fAuthData.providerData["profileImageURL"])")
                        let displayName = self.stringFormatting("\(fAuthData.providerData["displayName"])")
                        let user = ["provider": fAuthData.provider!,"email":email!,"name":name!,"gender":gender!,"profileImageURL":profileImage,"displayName":displayName]
                        DataService.instance.createFirebaseUser(fAuthData.uid, user: user)
                        NSUserDefaults.standardUserDefaults().setValue(fAuthData.uid, forKey: KEY_UID)
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        self.performSegueWithIdentifier("firstTimeLoginSegue", sender: nil)
                    }
                    
                })
            }
        }
        
        
        
        
        
        
        
        
        
        
    }
    
    @IBAction func attemptLogin(sender: AnyObject) {
        
        if let email = emailTextField.text where email != "" , let pwd = passwordTextField.text where pwd != ""{
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "New User Authenticating"
            
            DataService.instance.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (attemptError,authData) -> Void in
                if attemptError != nil {
                    if attemptError.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.instance.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { (ErrorType, AnyObject) -> Void in
                            if ErrorType != nil {
                               let alert =  DataService.instance.showErrorAlertSimple("Could Not Create Account", msg: "Problem Creating. Try Something Else")
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(AnyObject[KEY_UID], forKey: KEY_UID)
                                DataService.instance.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (ErrorType, fAuthData) -> Void in
                                    let providerSplit = email.characters.split("@")
                                    let providerSplitDot = String(providerSplit.last!).characters.split(".")
                                    let providerName = String(providerSplitDot.first!)
                                    print("Logged in! \(fAuthData)")
                                    let profileImageString = "\(fAuthData.providerData["profileImageURL"])"
                                    let defaultProfilePic = self.stringFormatting(profileImageString)
                                    let user = ["provider": providerName,"email":email,"profileImageURL":defaultProfilePic]
                                    DataService.instance.createFirebaseUser(fAuthData.uid, user: user)
                                })
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                       
                    } else {
                        let alert = DataService.instance.showErrorAlertSimple("Could Not Login", msg: "Please Check you Username or Password")
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            let alert = DataService.instance.showErrorAlertSimple("Email and Password Required", msg: "You must enter an Email and Password")
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    
    func stringFormatting(rawString : String)->String {
        
        let profilePic = rawString.stringByReplacingOccurrencesOfString("Optional(", withString: "")
        let finshedString = profilePic.stringByReplacingOccurrencesOfString(")", withString: "")
        
        return finshedString
        
    }
    

}

