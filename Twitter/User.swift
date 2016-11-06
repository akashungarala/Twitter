//
//  User.swift
//  Twitter
//
//  Created by Akash Ungarala on 10/31/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class User: NSObject {
    
    static let userDidLogoutNotification = "UserDidLogout"
    
    static var _currentUser: User?
    var name:String?
    var screenname:String?
    var tagline: String?
    var numFollowers: Int
    var numFollowing: Int
    var numTweets: Int
    var profileUrl:URL?
    var profileBackgroundImageUrl: URL?
    var dictionary:NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        tagline = dictionary["description"] as? String
        numFollowers = (dictionary["followers_count"] as? Int)!
        numFollowing = (dictionary["friends_count"] as? Int)!
        numTweets = (dictionary["statuses_count"] as? Int)!
        let profileUrlString = dictionary["profile_image_url"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
        let backgroundImageURLString = dictionary["profile_background_image_url_https"] as? String
        if backgroundImageURLString != nil {
            profileBackgroundImageUrl = URL(string: backgroundImageURLString!)!
        } else {
            profileBackgroundImageUrl = nil
        }
    }
    
    class var currentUser: User? {
        get {
            if(_currentUser == nil){
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? NSData
                if let userData = userData {
                    do {
                        if let dataDictionary = try? JSONSerialization.jsonObject(with: userData as Data, options: []) as?NSDictionary {
                            _currentUser = User(dictionary: dataDictionary!)
                        }
                    }
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.set(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
    
}
