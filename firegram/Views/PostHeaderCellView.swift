//
//  PostHeaderCellView.swift
//  Makestagram
//
//  Created by Brian Hans on 6/25/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import DateTools

class PostHeaderCellView: UITableViewCell{
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    var post: Post?{
        didSet{
            if let post = post{
                usernameLabel.text = post.username
                
                dateCreatedLabel.text = post.date.shortTimeAgoSinceDate(NSDate()) ?? ""
            }
        }
    }
    
}