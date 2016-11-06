//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/1/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

@objc protocol ComposeTweetViewControllerDelegate {
    @objc optional func tweetComposed(composeViewController: ComposeTweetViewController, newTweet: Tweet)
}

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var replyToLabel: UILabel!
    @IBOutlet weak var replyToView: UIView!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var composeTweetTextView: UITextView!
    @IBOutlet weak var newTweetView: UIView!
    @IBOutlet weak var newTweetProfileImage: UIImageView!
    @IBOutlet weak var newTweetUserNameLabel: UILabel!
    @IBOutlet weak var newTweetScreenNameLabel: UILabel!
    
    let client = TwitterClient.sharedInstance
    
    weak var newTweetDelegate:ComposeTweetViewControllerDelegate?
    var segueIdentifier:String?
    var replyTweet:Tweet?
    var replyToTweetPrefix:String?
    let tweetLimit = 140
    var loadingStateView:LoadingIndicatorView?
    var isDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        composeTweetTextView.delegate = self
        tweetButton.layer.cornerRadius = 5
        tweetButton.clipsToBounds = true
        self.automaticallyAdjustsScrollViewInsets = false
        tweetButton.isEnabled = false
        if User.currentUser?.profileUrl != nil {
            newTweetProfileImage.alpha = 0
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.newTweetProfileImage.setImageWith((User.currentUser?.profileUrl!)!)
                self.newTweetProfileImage.alpha = 1
            }, completion: nil)
        }
        newTweetUserNameLabel.text = User.currentUser?.name
        newTweetScreenNameLabel.text = "@" + (User.currentUser?.screenname!)!
        if (segueIdentifier == "NewTweet") {
            replyToView.isHidden = true
        } else {
            if let replyTweet = replyTweet {
                replyToView.isHidden = false
                replyToTweetPrefix = "@\((replyTweet.user?.screenname)!)"
                replyToLabel.text = "In reply to \((replyTweet.user?.screenname)!)"
                composeTweetTextView.text = " "
                composeTweetTextView.becomeFirstResponder()
            }
        }
        setUpLoadingIndicator()
        hideLoadingIndicator()
    }
    
    @IBAction func onComposeTweet(_ sender: AnyObject) {
        showLoadingIndicator()
        var twText = composeTweetTextView.text!
        var replyToID = Int64.max
        if (replyTweet != nil) {
            twText = composeTweetTextView.text!
            twText = replyToTweetPrefix! + composeTweetTextView.text!
            replyToID = (replyTweet?.tweetID)!
        } else {
            replyToID = 0
        }
        if (composeTweetTextView.text.characters.count > 0) {
            client?.composeTweet(tweetText: twText, inReplyTo: Int64(replyToID)) { (response, error) in
                if (error != nil) {
                    self.hideLoadingIndicator()
                } else {
                    self.hideLoadingIndicator()
                    let tweetRes = Tweet(dictionary: response as! NSDictionary)
                    self.newTweetDelegate?.tweetComposed!(composeViewController: self, newTweet: tweetRes)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.hideLoadingIndicator()
        }
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setUpLoadingIndicator() {
        var middleY = UIScreen.main.bounds.size.height/2;
        if (self.navigationController != nil) {
            middleY  = middleY - self.navigationController!.navigationBar.frame.height
        }
        let frame = CGRect(x: 0, y: middleY, width: self.view.bounds.size.width, height: LoadingIndicatorView.defaultHeight)
        loadingStateView = LoadingIndicatorView(frame: frame)
        loadingStateView!.isHidden = true
        self.view.addSubview(loadingStateView!)
    }
    
    private func showLoadingIndicator() {
        isDataLoading = true
        loadingStateView!.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        isDataLoading = false
        loadingStateView!.stopAnimating()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentLength = composeTweetTextView.text.characters.count
        if (currentLength > 0) {
            tweetButton.isEnabled = true
        } else {
            tweetButton.isEnabled = false
        }
        if (range.length + range.location > currentLength) {
            return false
        }
        let newLength = currentLength + text.characters.count - range.length
        let newLenghtAllowed = newLength <= tweetLimit
        if newLenghtAllowed {
            tweetCountLabel.text = "\(tweetLimit - newLength)"
        }
        return newLenghtAllowed
    }
    
}
