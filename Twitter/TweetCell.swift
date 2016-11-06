//
//  TweetCell.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/1/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    @objc optional func tweetReplied(updatedCellTweet: Tweet, controlCell: TweetCell)
    func thumbImageClicked(tweetCell: TweetCell!)
}

class TweetCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var tweetTypeDescriptionLabel: UILabel!
    @IBOutlet weak var tweetTypeDescriptionImageView: UIImageView!
    
    let client = TwitterClient.sharedInstance
    
    weak var cellDelegate:TweetCellDelegate?
    
    var cellTweet:Tweet! {
        didSet {
            fillCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onProfileImage(_ sender: UIButton) {
        cellDelegate?.thumbImageClicked(tweetCell: self)
    }
    
    @IBAction func onReply(_ sender: AnyObject) {
        cellDelegate?.tweetReplied!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
    @IBAction func OnRetweet(_ sender: AnyObject) {
        if (cellTweet.curUserReTweeted)! {
            cellTweet.curUserReTweeted = false
            cellTweet.retweetCount -= 1
            client?.UndoRetweet(tweetId: cellTweet.tweetID!, completion: { (response:AnyObject?, error:Error?) in
                if (error != nil) {
                    self.cellTweet.curUserReTweeted = true
                    self.cellTweet.retweetCount += 1
                }
                self.updateRetweetView()
            })
        } else {
            cellTweet.curUserReTweeted = true
            cellTweet.retweetCount += 1
            client?.retweetATweet(tweetId: cellTweet.tweetID!, completion: { (response, error) in
                if (error != nil) {
                    self.cellTweet.curUserReTweeted = false
                    self.cellTweet.retweetCount -= 1
                }
                self.updateRetweetView()
            })
        }
    }
    
    @IBAction func onFavoriteOrHeart(_ sender: AnyObject) {
        if (cellTweet.curUserFavorited)! {
            cellTweet.curUserFavorited = false
            cellTweet.favoritesCount -= 1
            client?.unFavoriteATweet(tweetId: cellTweet.tweetID!, completion: { (response:AnyObject?, error:Error?) in
                if (error != nil) {
                    self.cellTweet.curUserFavorited = true
                    self.cellTweet.favoritesCount += 1
                }
                self.updateFavoriteView()
            })
        } else {
            cellTweet.curUserFavorited = true
            cellTweet.favoritesCount += 1
            client?.favoriteATweet(tweetId: cellTweet.tweetID!, completion: { (response, error) in
                if (error != nil) {
                    self.cellTweet.curUserFavorited = false
                    self.cellTweet.favoritesCount -= 1
                }
                self.updateFavoriteView()
            })
        }
    }
    
    func fillCell() {
        if cellTweet.user?.profileUrl != nil {
            profileImageView.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.profileImageView.setImageWith((self.cellTweet.user?.profileUrl!)!)
                self.profileImageView.alpha = 1
            }, completion: nil)
        }
        nameLabel.text = cellTweet.user?.name
        usernameLabel.text = "@" + (cellTweet.user?.screenname!)!
        timeStampLabel.text = cellTweet.timestamp
        tweetTextLabel.attributedText = Tweet.hashTagMentions(str: cellTweet.text!)
        if (cellTweet.tweetType == TweetType.Retweet) {
            if (cellTweet.curUserReTweeted!) {
                tweetTypeDescriptionLabel.text = "You retweeted"
                tweetTypeDescriptionImageView.image = UIImage(named: "Retweet On")
            } else {
                tweetTypeDescriptionLabel.text =  "\((cellTweet.retweetedUser?.name)!) retweeted"
                tweetTypeDescriptionImageView.image = UIImage(named: "Retweet Off")
            }
            tweetTypeDescriptionLabel.isHidden = false
            tweetTypeDescriptionImageView.isHidden = false
        } else if(cellTweet.tweetType == TweetType.Reply) {
            tweetTypeDescriptionLabel.text = "In reply to " + cellTweet.inReplyToScreenName!
            tweetTypeDescriptionImageView.image = UIImage(named: "Reply")
            tweetTypeDescriptionLabel.isHidden = false
            tweetTypeDescriptionImageView.isHidden = false
        } else {
            tweetTypeDescriptionLabel.text = ""
            tweetTypeDescriptionLabel.isHidden = true
            tweetTypeDescriptionImageView.isHidden = true
        }
        updateFavoriteView()
        updateRetweetView()
    }
    
    func updateFavoriteView() {
        if (cellTweet.curUserFavorited!) {
            heartButton.setImage(UIImage(named: "Like On"), for: .normal)
        } else {
            heartButton.setImage(UIImage(named: "Like Off"), for: .normal)
        }
        heartLabel.text = "\(cellTweet.favoritesCount)"
    }
    
    func updateRetweetView() {
        if (cellTweet.curUserReTweeted!) {
            retweetBtn.setImage(UIImage(named: "Retweet On"), for: .normal)
        } else {
            retweetBtn.setImage(UIImage(named: "Retweet Off"), for: .normal)
        }
        retweetLabel.text = "\(cellTweet.retweetCount)"
    }
    
}
