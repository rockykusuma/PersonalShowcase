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
class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

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
            if facebookError != nil {
                print("Facebook Login Failed. Error \(facebookError)")
            }else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Succesfully logged in to Facebook with Access Token : \(accessToken)")
                
                DataService.instance.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, authData) -> Void in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(authData)")
                        
                        
                        let user = ["provider": authData.provider!, "blah" : "Test"]
                        DataService.instance.createFirebaseUser(authData.uid, user: user)
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                    
                })
            }
        }
        
    }
    
    @IBAction func attemptLogin(sender: AnyObject) {
        
        if let email = emailTextField.text where email != "" , let pwd = passwordTextField.text where pwd != ""{
            DataService.instance.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (attemptError,authData) -> Void in
                if attemptError != nil {
                    if attemptError.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.instance.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { (ErrorType, AnyObject) -> Void in
                            if ErrorType != nil {
                               let alert =  DataService.instance.showErrorAlert("Could Not Create Account", msg: "Problem Creating. Try Something Else")
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(AnyObject[KEY_UID], forKey: KEY_UID)
                                DataService.instance.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { (ErrorType, fAuthData) -> Void in
                                    
                                    let user = ["provider": fAuthData.provider!, "blah" : "emailTest"]
                                    DataService.instance.createFirebaseUser(fAuthData.uid, user: user)
                                })
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
             
                            
                        })
                       
                    } else {
                        let alert = DataService.instance.showErrorAlert("Could Not Login", msg: "Please Check you Username or Password")
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            let alert = DataService.instance.showErrorAlert("Email and Password Required", msg: "You must enter an Email and Password")
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
//    func showErrorAlert(title: String, msg: String){
//        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
//        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
//        alert.addAction(action)
//        presentViewController(alert, animated: true, completion: nil)
//        
//    }
}

