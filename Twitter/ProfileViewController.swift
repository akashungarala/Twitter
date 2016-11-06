//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/1/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var numTweetsLabel: UILabel!
    @IBOutlet weak var numFollowersLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = tweet.user!.name!
        screenNameLabel.text = "@\(tweet.user!.screenname!)"
        numTweetsLabel.text = String(tweet.user!.numTweets)
        numFollowersLabel.text = String(tweet.user!.numFollowers)
        numFollowingLabel.text = String(tweet.user!.numFollowing)
        if tweet.user!.profileUrl != nil {
            thumbImageView.setImageWith(tweet.user!.profileUrl!)
        }
        if tweet.user!.profileBackgroundImageUrl != nil {
            backgroundImageView.setImageWith(tweet.user!.profileBackgroundImageUrl!)
        }
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
    }

}
