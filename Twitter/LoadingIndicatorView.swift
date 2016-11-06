//
//  LoadingIndicatorView.swift
//  Twitter
//
//  Created by Akash Ungarala on 11/5/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class LoadingIndicatorView: UIView {
    
    static let defaultHeight:CGFloat = 50.0
    
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
        activityIndicatorView.center = CGPoint(x:self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.color = UIColor.black
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
