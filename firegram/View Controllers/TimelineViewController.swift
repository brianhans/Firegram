//
//  TimelineViewController.swift
//  firegram
//
//  Created by Brian Hans on 6/26/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class TimelineViewController: UIViewController{
    
    let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    let storageRef: FIRStorageReference = FIRStorage.storage().referenceForURL("gs://firegram-d1065.appspot.com")
    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tabBarController?.delegate = self
        
        
        FirebaseHelper.timeLineRequestForCurrentUser{ (posts: [Post]?) -> Void in
            if let posts = posts{
                self.posts = posts
            }
            
            self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: self.tableView.contentOffset.y + 510)
            self.tableView.reloadData()
        }
    }
    
}

extension TimelineViewController: UITableViewDataSource{
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! PostHeaderCellView
        
        headerCell.post = posts[section]
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    //Responsible for creating the correct number of cells which are now sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
    }
    
    //One row is used and will display several sections
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Updates the images in the cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Casting to the sepecific type allows access to references to the cells components
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        
        let post = posts[indexPath.section]
        post.downloadImage()
        cell.post = post
        
        return cell
    }
}

//MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate{
    
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if(viewController is PhotoViewController){
            takePhoto()
            return false
        }else{
            return true
        }
    }
    
    //Sets the callback of the phototakinghelper to upload the image when it finishes
    func takePhoto(){
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) {(image: UIImage?, info: [String: AnyObject]?) in
            //generates path at userid and assigns random name
            let photoReference = self.storageRef.child(FIRAuth.auth()!.currentUser!.uid + "/\(NSDate.timeIntervalSinceReferenceDate() * 1000)")
            let imageData = UIImageJPEGRepresentation(image!, 0.01)!
            
            let uploadTask = photoReference.putData(imageData, metadata: nil){(metadata, error) in
                if let error = error{
                    print(error.localizedDescription)
                    ErrorHandling.defaultErrorHandler(error)
                }
                
                
                let path = photoReference.fullPath
                
                //Stores date as time since 1970 so it will fit in database
                self.ref.child(Constants.FirebaseCatagories.posts).child(FIRAuth.auth()!.currentUser!.uid).childByAutoId().setValue(["path": path, "date": NSDate().timeIntervalSince1970, "username": FirebaseHelper.currentUser.username])
                
                
            }
            
        }
    }
}