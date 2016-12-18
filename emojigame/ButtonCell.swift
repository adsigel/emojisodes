//
//  ButtonCell.swift
//  emojigame
//
//  Created by Adam Sigel on 12/18/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import UIKit
import AnalyticsSwift

class ButtonCell: UITableViewCell {
    var tapAction: ((UITableViewCell) -> Void)?
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    
    @IBOutlet weak var rowLabel: UILabel!
    
    @IBAction func buttonTap(sender: AnyObject) {
        tapAction?(self)
    }
}
