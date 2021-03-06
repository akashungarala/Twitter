//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/1/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeTweetViewControllerDelegate, TweetDetailsViewControllerDelegate, UIScrollViewDelegate, TweetCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var tweets:[Tweet]!
    var tweetForSegue: Tweet?
    var refreshControl:UIRefreshControl!
    var loadingStateView:LoadingIndicatorView?
    var loadingMoreView:InfiniteScrollActivityView?
    var isDataLoading = false
    var isMoreDataLoading = false
    var resultsPageOffset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        setupScrollLoadingMoreIndicator()
        hideNetworkErrorView()
        setupRefreshControl()
        setUpLoadingIndicator()
        showLoadingIndicator()
        getOrRefreshTweets()
    }
    
    func getOrRefreshTweets() {
        showLoadingIndicator()
        let client = TwitterClient.sharedInstance
        var lowestTweetID = Int64.max
        if (isMoreDataLoading) {
            for lTweetObj in tweets {
                if (lTweetObj.tweetID < lowestTweetID) {
                    lowestTweetID = lTweetObj.tweetID
                }
            }
            lowestTweetID = lowestTweetID - 1
        } else {
            lowestTweetID = 0
        }
        client?.homeTimeline(lowestTweetId: lowestTweetID, success: { (tweets:[Tweet]) in
            self.refreshControl.endRefreshing()
            if (self.isMoreDataLoading) {
                self.isMoreDataLoading = false
                self.tweets.append(contentsOf: tweets)
                self.loadingMoreView!.stopAnimating()
            } else {
                self.tweets = tweets
            }
            self.tableView.reloadData()
            self.hideLoadingIndicator()
        }, failure: {(error : Error) -> () in
            self.hideLoadingIndicator()
            self.showNetworkErrorView()
            self.loadingMoreView!.stopAnimating()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                let frame = CGRect(x:0,y: tableView.contentSize.height, width: tableView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                getOrRefreshTweets()
            }
        }
    }
    
    func tweetComposed(composeViewController: ComposeTweetViewController, newTweet: Tweet) {
        tweets.insert(newTweet, at: 0)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    func tweetComposedFromDetail(composeViewController: ComposeTweetViewController, newTweet: Tweet) {
        tweets.insert(newTweet, at: 0)
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    func tweetUpdated(updatedCellTweet: Tweet, tweetObjIndex: Int) {
        tweets[tweetObjIndex] = updatedCellTweet
        let rowIndexPath = IndexPath.init(row: tweetObjIndex , section: 0)
        tableView.reloadRows(at: [rowIndexPath], with: UITableViewRowAnimation.fade)
    }
    
    func tweetReplied(updatedCellTweet: Tweet, controlCell: TweetCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeTweetViewController
        vc.replyTweet = updatedCellTweet
        vc.newTweetDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func thumbImageClicked (tweetCell: TweetCell!) {
        tweetForSegue = tweetCell.cellTweet! as Tweet
        performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let tweetObj = tweets[indexPath.row]
        cell.cellTweet = tweetObj
        cell.cellDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = indexPath
    }
    
    private func showNetworkErrorView() {
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.networkErrorView.isHidden = false
            self.networkErrorView.frame.size.height = 44
            self.networkErrorView.alpha = 1
        }, completion: nil)
    }
    
    private func hideNetworkErrorView() {
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.networkErrorView.isHidden = true
            self.networkErrorView.frame.size.height = 0
            self.networkErrorView.alpha = 0
        }, completion: nil)
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getOrRefreshTweets), for: UIControlEvents.valueChanged)
        let attributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        let attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        refreshControl.attributedTitle = attributedTitle
        refreshControl.tintColor = UIColor.black
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    private func setUpLoadingIndicator() {
        var middleY = UIScreen.main.bounds.size.height/2;
        middleY  = middleY - self.navigationController!.navigationBar.frame.height
        let frame = CGRect(x: 0, y: middleY, width: tableView.bounds.size.width, height: LoadingIndicatorView.defaultHeight)
        loadingStateView = LoadingIndicatorView(frame: frame)
        loadingStateView!.isHidden = true
        tableView.addSubview(loadingStateView!)
    }
    
    func setupScrollLoadingMoreIndicator() {
        let frame = CGRect(x:0, y:tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    private func showLoadingIndicator() {
        isDataLoading = true
        loadingStateView!.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        isDataLoading = false
        loadingStateView!.stopAnimating()
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? TweetDetailsViewController {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: cell)
                let tweetObj = tweets![indexPath!.row]
                detailViewController.tweetObj = tweetObj
                detailViewController.tweetObjIndex = indexPath!.row
                detailViewController.detailDelegate = self
                detailViewController.navigationItem.leftBarButtonItem?.title = ""
                detailViewController.navigationItem.titleView?.tintColor = UIColor.black
            }
        } else if let navController = segue.destination as? UINavigationController {
            if (segue.identifier == "NewTweet") {
                let newTweetVC =  navController.topViewController as! ComposeTweetViewController
                newTweetVC.newTweetDelegate = self
                newTweetVC.segueIdentifier = "NewTweet"
            }
        } else if let detailViewController = segue.destination as? ProfileViewController {
            detailViewController.tweet = tweetForSegue
        }
    }
    
}
