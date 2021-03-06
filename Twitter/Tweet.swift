//
//  Tweet.swift
//  Twitter
//
//  Created by Akash Ungarala on 10/31/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//
import UIKit
import Foundation

enum TweetType: String {
    case Retweet, Reply, Original
}

class Tweet: NSObject {
    
    var text:String?
    var timestampDt:NSDate?
    var timestamp:String?
    var retweetCount = 0
    var favoritesCount = 0
    var createdAt:String?
    var user:User?
    var curUserReTweeted:Bool?
    var curUserFavorited:Bool?
    var tweetID:Int64!
    var inReplyToScreenName:String?
    var retweetedStatus:NSDictionary?
    var tweetType:TweetType?
    var retweetedUser:User?
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        user = User(dictionary:dictionary["user"] as! NSDictionary)
        let twID = dictionary["id"]!
        tweetID = (twID as! NSNumber).int64Value
        let timestampString = dictionary["created_at"] as? String
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestampDt = formatter.date(from: timestampString) as NSDate?
            timestamp = Tweet.shortTimeAgoSinceDate(date: timestampDt!)
            formatter.dateFormat = "MM/dd/yy, h:mm aa";
            createdAt = formatter.string(from: timestampDt as! Date)
        }
        curUserFavorited = dictionary["favorited"] as? Bool
        curUserReTweeted =  dictionary["retweeted"] as? Bool
        inReplyToScreenName = dictionary["in_reply_to_screen_name"] as? String
        retweetedStatus = dictionary["retweeted_status"] as? NSDictionary
        if (retweetedStatus != nil) {
            tweetType = TweetType.Retweet
            retweetedUser = user
            user = User(dictionary: retweetedStatus!["user"] as! NSDictionary)
        } else if (inReplyToScreenName != nil) {
            tweetType = TweetType.Reply
        } else {
            tweetType = TweetType.Original
        }
    }
    
    class func tweetsWithArray(dictionaries:[NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets
    }
    
    class func shortTimeAgoSinceDate(date: NSDate) -> String {
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.weekOfYear, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: earliest, to: latest as Date)
        if (components.year! >= 1) {
            return "\(components.year!)y"
        } else if (components.month! >= 1) {
            return "\(components.month!)m"
        } else if (components.weekOfYear! >= 1) {
            return "\(components.weekOfYear!)w"
        } else if (components.day! >= 1) {
            return "\(components.day!)d"
        } else if (components.hour! >= 1) {
            return "\(components.hour!)h"
        } else if (components.minute! >= 1) {
            return "\(components.minute!)m"
        } else if (components.second! >= 3) {
            return "\(components.second!)s"
        } else {
            return "now"
        }
    }
    
    class func hashTagMentions(str:String) -> NSMutableAttributedString  {
        let nsText:NSString = str as NSString
        let words:[String] = nsText.components(separatedBy: " ")
        let attrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 13.0)]
        let attrString = NSMutableAttributedString.init(string: str, attributes: attrs)
        // tag each word if it has a hashtag
        for word in words {
            if word.hasPrefix("#") {
                // a range is the character position, followed by how many characters are in the word.
                let matchRange:NSRange = nsText.range(of: word)
                var stringifiedWord:String = word as String
                // drop the hashtag
                stringifiedWord = String(stringifiedWord.characters.dropFirst())
                let digits = NSCharacterSet.decimalDigits
                if stringifiedWord.rangeOfCharacter(from: digits) != nil {
                    // hashtag contains a number, like "#1"so don't make it clickable
                } else {
                    // set a link for when the user clicks on this word.
                    attrString.addAttribute(NSLinkAttributeName, value: "https://twitter.com/hashtag/\(stringifiedWord)?src=hash", range: matchRange)
                }
            }
            if word.hasPrefix("@") {
                let matchRange:NSRange = nsText.range(of: word)
                var stringifiedWord:String = word as String
                stringifiedWord = String(stringifiedWord.characters.dropFirst())
                let digits = NSCharacterSet.decimalDigits
                if stringifiedWord.rangeOfCharacter(from: digits) != nil {
                } else {
                    attrString.addAttribute(NSLinkAttributeName, value: "https://twitter.com/\(stringifiedWord)", range: matchRange)
                }
            }
        }
        return attrString
    }
    
}
