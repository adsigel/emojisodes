//
//  FirstTimeController.swift
//  emojigame
//
//  Created by Adam Sigel on 8/24/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import UIKit
import AnalyticsSwift

class FirstTimeController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    @IBOutlet weak var explainerText: UILabel!
    @IBOutlet weak var doTogether: UILabel!
    @IBOutlet weak var checkMark: UIButton!
    
    
    override func viewDidLoad() {
        analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Begin").userId(uzer))
        self.explainerText.text = "It's a 🎬 guessing game with 😀👍."
        analytics.flush()
    }
    
    
    @IBAction func nextButton(sender: AnyObject) {
        let step1 = "It's a 🎬 guessing game with 😀👍."
        let step2 = "We'll show you a bunch of 👱👩💔☔️💑 that represent the plot of a 🎬."
        let step3 = "You can 🤔 for hints, but it will cost you points."
        let step4 = "If the hints aren't helpful, try 💬 with friends."
        let step5 = "If all else fails, you can 🚫 for now."
        let step6 = "You can ➕ to Emojisodes with your own 🎬 too!"
        
        if self.explainerText.text == step1 {
            self.explainerText.text = step2
            analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Step 2").userId(uzer))
            analytics.flush()
            }
        else if self.explainerText.text == step2 {
            self.explainerText.text = step3
            analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Step 3").userId(uzer))
            analytics.flush()
            }
        else if self.explainerText.text == step3 {
            self.explainerText.text = step4
            analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Step 4").userId(uzer))
            analytics.flush()
            }
        else if self.explainerText.text == step4 {
            self.explainerText.text = step5
            analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Step 5").userId(uzer))
            analytics.flush()
            }
        else if self.explainerText.text == step5 {
            self.explainerText.text = step6
            analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Step 6").userId(uzer))
            analytics.flush()
            }
        else if self.explainerText.text == step6 {
            self.doTogether.hidden = false
            self.checkMark.hidden = false
            analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Complete").userId(uzer))
            analytics.flush()
            }
        }
    
    
    @IBAction func checkMarkButton(sender: AnyObject) {
        performSegueWithIdentifier("tryOne", sender: sender)
        analytics.flush()
    }
    
    
}
