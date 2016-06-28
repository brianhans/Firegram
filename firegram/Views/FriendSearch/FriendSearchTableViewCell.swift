//
//  FriendSearchTableViewCell.swift
//  Makestagram
//
//  Created by Brian Hans on 6/24/16.
//  Copyright © 2016 Make School. All rights reserved.


import UIKit

protocol FriendSearchTableViewCellDelegate: class {
    func cell(cell: FriendSearchTableCell, didSelectFollowUser user: User)
    func cell(cell: FriendSearchTableCell, didSelectUnfollowUser user: User)
}

class FriendSearchTableCell: UITableViewCell{

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    weak var delegate: FriendSearchTableViewCellDelegate?
    
    var user: User?{
        didSet{
            usernameLabel.text = user?.username
        }
    }
    
    var canFollow: Bool? = true {
        didSet{
            //changes button image based on if user unfollowed or followed user
            if let canFollow = canFollow {
                followButton.selected = !canFollow
            }
        }
    }
    
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        if let canFollow = canFollow where canFollow == true{
            delegate?.cell(self, didSelectFollowUser: user!)
            self.canFollow = false
        }else{
            delegate?.cell(self, didSelectUnfollowUser: user!)
            self.canFollow = true
        }
    }
}
