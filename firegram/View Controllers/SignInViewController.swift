//
//  SignInViewController.swift
//  firegram
//
//  Created by Brian Hans on 6/26/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func signInPressed(sender: AnyObject) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user: FIRUser?, error) in
            if let error = error{
                ErrorHandling.defaultErrorHandler(error)
                return
            }
            
            self.performSegueWithIdentifier(Constants.Segues.signInToHome, sender: nil)
        })
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        let email = emailTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if let error = error{
                print(error.localizedDescription)
                ErrorHandling.defaultErrorHandler(error)
                return
            }
            FirebaseHelper.currentUser = User(username: username, key: FIRAuth.auth()!.currentUser!.uid)
            let ref = FIRDatabase.database().reference()
            ref.child("users").child(user!.uid).setValue(["username": username])
            
            self.performSegueWithIdentifier(Constants.Segues.signInToHome, sender: nil)
        })
    }
}
