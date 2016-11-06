//
//  LoginViewController.swift
//  Twitter
//
//  Created by Akash Ungarala on 10/31/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        TwitterClient.sharedInstance?.login(success: {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }) { (error: Error) in
            print(error.localizedDescription)
        }
    }

}
