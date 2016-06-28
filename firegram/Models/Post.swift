//
//  Post.swift
//  firegram
//
//  Created by Brian Hans on 6/27/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import Bond
import ConvenienceKit


class Post: NSObject{
    
    static var imageCache: NSCacheSwift<String, UIImage> = NSCacheSwift<String, UIImage>()
    
    var imagePath: String
    var date: NSDate
    var key: String
    var username: String
    
    var image: Observable<UIImage?> = Observable(nil)
    var likes: Observable<[String]?> = Observable(nil)
    
    let storageRef: FIRStorageReference
    
    init(imagePath: String, date: NSNumber, key: String, username: String){
        self.imagePath = imagePath
        self.date = NSDate(timeIntervalSince1970: NSTimeInterval(date))
        self.key = key
        self.username = username
        
        storageRef = FIRStorage.storage().reference()
        super.init()
        fetchLikes()
        
    }
    
    func downloadImage(){
        
        image.value = Post.imageCache[self.imagePath]
        
        if(image.value == nil){
            FIRStorage.storage().referenceWithPath(imagePath).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error{
                    print(error.localizedDescription)
                }
                
                if let data = data{
                    self.image.value = UIImage(data: data, scale: 1.0)
                    
                    Post.imageCache[self.imagePath] = self.image.value
                }
                
            }
        }
    }

    
    func fetchLikes(){
        FirebaseHelper.likesForPost(self){(likes: [String])in
            self.likes.value = likes
        }
    }
    
    func toggleLikePost(user: String){
        
        let username = FirebaseHelper.currentUser.username
        
        if(self.likes.value!.contains(username)){
            FirebaseHelper.unlikePost(username, post: self)
        }else{
            FirebaseHelper.likePost(username, post: self)
        }
        
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if(imagePath == (object as? Post)!.imagePath){
            return true
        }
        return false
    }
}


