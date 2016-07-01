//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Brian Hans on 6/23/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Bond
import Firebase

//Contains the links to the storyboard for each cell
class PostTableViewCell: UITableViewCell{
    
    var postDisposable: DisposableType?
    var likesDisposable: DisposableType?
    
    weak var timeline: TimelineViewController?
    

    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    
    var post: Post?{
        
        didSet{
            postDisposable?.dispose()
            likesDisposable?.dispose()
            
            //Free the old image reference when it is not displayed
            if let oldValue = oldValue where oldValue != post {
                oldValue.image.value = nil
            }
            
            if let post = post{
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                likesDisposable = post.likes.observe({ (value: [String]?) -> Void in
                    if let value = value{
                        self.likesLabel.text = self.stringFromUserList(value)
                        self.likeButton.selected = value.contains(FirebaseHelper.currentUser.username)
                        self.likesIconImageView.hidden = (value.count == 0)
                    }else{
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                    
                })
            }
        }
    }
    
    
    func stringFromUserList(userList: [String]) -> String{
        return userList.joinWithSeparator(",")
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(FIRAuth.auth()!.currentUser!.email!)
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
        do{
            try FIRAuth.auth()?.signOut()
            
            timeline?.performSegueWithIdentifier("signOut", sender: nil)
        }catch{
        }
    }
    
    
    @IBAction func moreButtonPressed(sender: AnyObject) {
        
        
    }
}
