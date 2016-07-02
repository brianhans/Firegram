//
//  AppDelegate.swift
//  firegram
//
//  Created by Brian Hans on 6/26/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FIRApp.configure()
        if let user = FIRAuth.auth()!.currentUser{
            FIRDatabase.database().reference().child(Constants.FirebaseCatagories.users).child(user.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                
                if let username = snapshot.value as? String{
                    FirebaseHelper.currentUser = User(username: username, key: FIRAuth.auth()!.currentUser!.uid)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                    self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarController")
                    self.window?.makeKeyAndVisible()
                }
            })
            
        }
        
        return true
    }

}

