//
//  ServerTableViewCell.swift
//  MoodleTouch
//
//  Created by Adam Bratin on 11/25/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {
    @IBOutlet var serverLabel: UILabel!// = UILabel()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
    }
    
    func loadCell(server : String) {
        self.serverLabel.text = server
    }
}
