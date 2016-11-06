//
//  TweetDetailsViewController.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/1/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//


import UIKit

@objc protocol TweetDetailsViewControllerDelegate {
    @objc optional func tweetUpdated(updatedCellTweet: Tweet, tweetObjIndex: Int)
    @objc optional func tweetComposedFromDetail(composeViewController: ComposeTweetViewController, newTweet: Tweet)
}

class TweetDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetControlsCellDelegate, ComposeTweetViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var detailDelegate:TweetDetailsViewControllerDelegate?
    
    var tweetObj:Tweet!
    var tweetObjIndex:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 190
        navigationItem.title = "Tweet"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.1
        }
        return 32.0
    }
    
    func favoriteRetweetUpdated(updatedCellTweet: Tweet, controlCell: TweetControlsCell) {
        let indexPath = tableView.indexPath(for: controlCell)!
        tweetObj = updatedCellTweet
        let rowIndexPath = IndexPath.init(row: indexPath.row - 1 , section: indexPath.section)
        tableView.reloadRows(at: [rowIndexPath], with: UITableViewRowAnimation.fade)
        detailDelegate?.tweetUpdated!(updatedCellTweet: updatedCellTweet, tweetObjIndex: tweetObjIndex)
    }
    
    func tweetRepliedFromDetail(updatedCellTweet: Tweet, controlCell: TweetControlsCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeTweetViewController
        vc.replyTweet = updatedCellTweet
        vc.newTweetDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func tweetComposed(composeViewController: ComposeTweetViewController, newTweet: Tweet) {
        detailDelegate?.tweetComposedFromDetail!(composeViewController: composeViewController, newTweet: newTweet)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetControlsCell", for: indexPath) as! TweetControlsCell
        cell.cellTweet = tweetObj
        cell.controlDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
}
