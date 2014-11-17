//
//  MoodleNavigationController.swift
//  Moodle
//
//  Created by Adam Bratin on 11/16/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit

class MoodleNavigationController: UINavigationController {
    @IBOutlet var URLField : UITextField!
    @IBOutlet var loadProgress : UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.URLField = UITextField(frame: CGRect(origin: CGPoint(x: 1.5 * self.navigationBar.frame.size.width/8, y: 10), size: CGSize(width: 6.5 * self.navigationBar.frame.size.width/8, height: 20)))
        self.URLField.borderStyle = UITextBorderStyle.RoundedRect
        self.URLField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.URLField.textAlignment = .Center
        self.URLField.font = UIFont(name: "System", size: 14)
        self.URLField.text = Constants.moodleURL + "conncoll.edu"
        self.URLField.hidden = true
        self.navigationBar.addSubview(URLField)
        self.loadProgress = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
        self.loadProgress.frame = CGRect(origin: CGPoint(x: 1.5 * self.navigationBar.frame.size.width/8, y: 30), size: CGSize(width: 6.5 * self.navigationBar.frame.size.width/8, height: 20))
        self.loadProgress.hidden = true
//        self.loadProgress.progress = 0.5
        self.navigationBar.addSubview(loadProgress)
        
    }

}
