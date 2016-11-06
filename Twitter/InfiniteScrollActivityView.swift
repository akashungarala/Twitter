//
//  InfiniteScrollActivityView.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/5/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class InfiniteScrollActivityView: UIView {
    
    static let defaultHeight:CGFloat = 60.0
    
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
    
}
