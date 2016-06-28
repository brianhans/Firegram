//
//  FriendSearchViewController.swift
//  firegram
//
//  Created by Brian Hans on 6/27/16.
//  Copyright © 2016 Brian Hans. All rights reserved.
//

import UIKit
import Firebase

class FriendSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    

    //Users from last search
    var users: [User]?
    
    //Local cache of users
    var followingUsers: [User]?{
        didSet{
            //Auto updates the table when the user clicks follow without contacting the server
            tableView.reloadData()
        }
    }
    
    
    enum State{
        case DefaultMode
        case SearchMode
    }
    
    
    var state: State = .DefaultMode{
        didSet {
            switch (state){
            case .DefaultMode:
                print("default mode")
                FirebaseHelper.allUsers{(data: [User]) in
                    self.users = data
                    self.tableView.reloadData()
                }
            case .SearchMode:
                //let searchText = searchBar?.text ?? ""
                print("search")
            }
        }
    }
    
    //MARK: Update user list
    
    func updateList(results: [User]?, error: NSError?){
        if let error = error{
            ErrorHandling.defaultErrorHandler(error)
        }
        
        //self.users = results as? [User] ?? []
        self.tableView.reloadData()
    }
    
    //MARK: Update Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .DefaultMode
        
        //Fill cache of user's followees
        FirebaseHelper.getFollowingUsersForUser(FirebaseHelper.currentUser.key) { (users: [User]) in
            self.followingUsers = users
        }
        
            }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

//Mark: TableView Data Source

extension FriendSearchViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendSearchTableCell
        
        let user = users![indexPath.row]
        cell.user = user
        
        if let followingUsers = followingUsers {
            //check is user if following user in cell and will change apperance
            cell.canFollow = !followingUsers.contains(user)
        }
        
        cell.delegate = self
        
        
        return cell
    }
}


//MARK: Searchabar Delegate

extension FriendSearchViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
}


//MARK: FriendSearchTableViewCell Deleate

extension FriendSearchViewController: FriendSearchTableViewCellDelegate {
    
    func cell(cell: FriendSearchTableCell, didSelectFollowUser user: User) {
        FirebaseHelper.addFollowRelationshipFromUser(FirebaseHelper.currentUser, toUser: user)
        //updates local cache
        followingUsers?.append(user)
    }
    
    func cell(cell: FriendSearchTableCell, didSelectUnfollowUser user: User) {
        if let followingUsers = followingUsers {
            FirebaseHelper.removeFollowRelationshipFromUser(FirebaseHelper.currentUser, toUser: user)
            self.followingUsers = followingUsers.filter({$0 != user})
        }
    }
    

}
