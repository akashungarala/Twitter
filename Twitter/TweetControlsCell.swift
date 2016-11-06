//
//  TweetControlsCell.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/5/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

@objc protocol TweetControlsCellDelegate {
    @objc optional func favoriteRetweetUpdated(updatedCellTweet: Tweet, controlCell: TweetControlsCell)
    @objc optional func tweetRepliedFromDetail(updatedCellTweet: Tweet, controlCell: TweetControlsCell)
}

class TweetControlsCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    let client = TwitterClient.sharedInstance
    
    weak var controlDelegate:TweetControlsCellDelegate?
    
    var cellTweet:Tweet! {
        didSet {
            fillCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onReply(_ sender: AnyObject) {
        controlDelegate?.tweetRepliedFromDetail!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
    @IBAction func onRetweet(_ sender: AnyObject) {
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
    
    @IBAction func onFavorite(_ sender: AnyObject) {
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
        screenNameLabel.text = "@" + (cellTweet.user?.screenname!)!
        timestampLabel.text = cellTweet.createdAt
        tweetTextLabel.attributedText = Tweet.hashTagMentions(str: cellTweet.text!)
        updateFavoriteView()
        updateRetweetView()
    }
    
    func updateFavoriteView() {
        favoriteCountLabel.text = "\(cellTweet.favoritesCount)"
        if (cellTweet.curUserFavorited!) {
            heartButton.setImage(UIImage(named: "Like On"), for: .normal)
        } else {
            heartButton.setImage(UIImage(named: "Like Off"), for: .normal)
        }
        controlDelegate?.favoriteRetweetUpdated!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
    func updateRetweetView() {
        retweetCountLabel.text = "\(cellTweet.retweetCount)"
        if (cellTweet.curUserReTweeted!) {
            retweetBtn.setImage(UIImage(named: "Retweet On"), for: .normal)
        } else {
            retweetBtn.setImage(UIImage(named: "Retweet Off"), for: .normal)
        }
        controlDelegate?.favoriteRetweetUpdated!(updatedCellTweet: cellTweet, controlCell: self)
    }
    
}
