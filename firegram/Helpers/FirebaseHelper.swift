//
//  FirebaseHelper.swift
//  firegram
//
//  Created by Brian Hans on 6/27/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import Firebase

class FirebaseHelper{
    
    static var currentUser: User!
    
    //MARK: Likes
    
    static func likePost(username: String, post: Post){
        let ref = FIRDatabase.database().reference()
        ref.child("likes").child(post.key).child(username).setValue([username: "liked"])
    }
    
    static func unlikePost(username: String, post: Post){
        let ref = FIRDatabase.database().reference()
        ref.child("likes").child(post.key).child(username).removeValue()
        
    }
    static func likesForPost(post: Post, completetionBlock: ([String]) -> Void){
        let ref = FIRDatabase.database().reference()
        
        ref.child("likes").child(post.key).observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            var likes: [String] = []
            for like in snapshot.children{
                likes.append(like.key)
            }
            completetionBlock(likes)
        }
    }
    
    //MARK: Following
    
    /**
     :param: user              The user that you want to find who they are following
     :param: completionBlock   Code to execute after it finds followers
     
     */
    static func getFollowingUsersForUser(path: String, completionBlock: ([User]) -> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(path).child("following").observeEventType(.Value) { (snapshot: FIRDataSnapshot) in
            var users: [User] = []
            
            for following in snapshot.children{
                let following = following as! FIRDataSnapshot
                let newUser = User(username: following.key, key: following.value!["key"] as! String)
                users.append(newUser)
            }
            completionBlock(users)
        }
    }
    
    /**
     :param: user      The user that will follow toUser
     :param: toUser    The user being followed
     
     */
    static func addFollowRelationshipFromUser(user: User, toUser: User){
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(user.key).child("following").child(toUser.username).setValue(["key": toUser.key])
    }
    
    /**
     Deletes follow relation
     
     :param: user      The user wants to unfollow toUser
     :param: toUser    The user being unfollowed
     
     */
    static func removeFollowRelationshipFromUser(user: User, toUser: User){
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(user.key).child("following").child(toUser.username).removeValue()
    }
    
    //MARK: Users
    
    /**
     
     Fetch all users expect the one currently logged in
     
     :param: completionBlock      The code that is run following the request
     :returns:                    The generated PFQuery
     
     */
    
    static func allUsers(completionBlock: ([User]) -> Void){
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            
            var users: [User] = []
            
            for user in snapshot.children{
                let data = user as! FIRDataSnapshot
                let username = data.value!["username"] as! String
                users.append(User(username: username, key: data.key))
            }
            users = users.filter{!$0.isEqual(currentUser)}
            completionBlock(users)
        }
    }
    
    /**
     Fetch users who name matches the search term
     
     :param: searchText         The search term used to find users
     :param: completionBlock    The code to be run after it finds the users
     
     :returns:                  The PFQuery for the users (so that we can use the reference to cancel later
     
     */
    static func searchUsers(searchText: String, completionBlock: [User] -> Void) -> FIRDatabaseQuery{
        let ref = FIRDatabase.database().reference()
        let query = ref.child("users").queryOrderedByChild("username").queryStartingAtValue(searchText)
        query.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            var users: [User] = []
            for user in snapshot.children{
                let data = user as! FIRDataSnapshot
                let username = data.value!["username"] as! String
                
                if(username == currentUser.username){
                    continue
                }
                
                let key = data.key
                users.append(User(username: username, key: key))
            }
            
            completionBlock(users)
        }
        
        return query
    }
    
    //MARK: FlaggedContent
    
    
    /**
     Flags a post of offensive content or spam
     
     :param: post               The post that you want to find the flags for
     :param: completionBlock    Code that runs after completed
     */
    static func getFlagsForPost(post: Any, completionBlock: Any ){
        
        
    }
    
    /**
     Flags a post of offensive content or spam
     
     :param: post    The post that is being flagged
     :param: user    The user flagging the post
     */
    static func flagPost(post: Any, user: Any){
        
    }
    
    
    static func timeLineRequestForCurrentUser(completionBlock: ([Post]) -> Void){
        
        
        let ref = FIRDatabase.database().reference()
        
        
        
        
        getFollowingUsersForUser(currentUser.key) { (users: [User]) in
            var posts: [Post] = []
            
            var allUsers = users
            
            if(!allUsers.contains(currentUser)){
                allUsers.append(currentUser)
            }
            
            for following in allUsers{
                ref.child("posts").child(following.key).observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
                    
                    let key = snapshot.key
                    let path = snapshot.value!["path"]! as! String
                    let username = snapshot.value!["username"] as! String
                    let date = snapshot.value!["date"] as! NSNumber
                    
                    let postFile = Post(imagePath: path, date: date, key: key, username: username)
                    
                    if(!posts.contains(postFile)){
                        posts.insert(postFile, atIndex: 0)
                    }
                    
                    
                    
                    posts.sortInPlace{$0.date.isLaterThan($1.date)}
                    completionBlock(posts)
                }
                
                ref.child("posts").child(following.key).observeEventType(.ChildRemoved) { (snapshot: FIRDataSnapshot) in
                    let key = snapshot.key
                    let path = snapshot.value!["path"]! as! String
                    let username = snapshot.value!["username"] as! String
                    let date = snapshot.value!["date"] as! NSNumber
                    
                    let postFile = Post(imagePath: path, date: date, key: key, username: username)
                    posts = posts.filter{$0.imagePath != postFile.imagePath}
                    completionBlock(posts)
                }
            }
        }
    }
        
}
