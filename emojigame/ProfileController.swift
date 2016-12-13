//
//  ProfileController.swift
//  emojigame
//
//  Created by Adam Sigel on 8/23/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import GameKit
import AnalyticsSwift

var gcScore : Int = 0

class ProfileController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, GKGameCenterControllerDelegate {
    
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var correctLabel: UIButton!
    @IBOutlet weak var submittedLabel: UILabel!
    @IBOutlet weak var trophyPersistence: UIButton!
    @IBOutlet weak var trophyFirst: UIButton!
    @IBOutlet weak var trophyCrayon: UIButton!
    @IBOutlet weak var trophyPencil: UIButton!
    @IBOutlet weak var trophy100: UIButton!
    @IBOutlet weak var trophyFirstRight: UIButton!
    @IBOutlet weak var trophyShare: UIButton!
    @IBOutlet weak var trophyStreak5: UIButton!
    @IBOutlet weak var trophySkip: UIButton!
    @IBOutlet weak var trophy1000: UIButton!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        print("Loading CreateProfile page.")
        self.correctLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        refreshUser()
        self.correctLabel.setTitle(String(userDict["correct"]!), forState: UIControlState.Normal)
        self.nameField.text = String(userDict["name"]!)
        self.emailField.text = String(userDict["email"]!)
        getSubmittedCount()
        getTrophies()
        print("userDict is \(userDict)")
    }
    
    @IBAction func viewMovieList(sender:AnyObject) {
        performSegueWithIdentifier("movieList", sender: sender)
    }
    
    
    @IBAction func finishUpButton(sender: AnyObject) {
        let name = nameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let email = emailField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let userRef = ref.child("users").child(uzer)
        userRef.child("name").setValue(name)
        userRef.child("email").setValue(email)
        comingBack = true
        analytics.flush()
        self.dismissViewControllerAnimated(true, completion: nil)        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func followTwitter(sender: AnyObject) {
        let url = NSURL(string: "https://twitter.com/emojisodes")!
        UIApplication.sharedApplication().openURL(url)
        analytics.enqueue(TrackMessageBuilder(event: "Viewed Twitter Profile").userId(uzer))
    }
    
    @IBAction func sendPraise(sender: AnyObject) {
        let url = NSURL(string: "https://itunes.apple.com/us/app/emojisodes/id1147295394?ls=1&mt=8")!
        UIApplication.sharedApplication().openURL(url)
        analytics.enqueue(TrackMessageBuilder(event: "Linked to App Store").userId(uzer))
    }
    
    @IBAction func showLeaderboard(sender: AnyObject) {
        saveHighscore(gcScore)
        showLeader()
        analytics.enqueue(TrackMessageBuilder(event: "Viewed Leaderboard").userId(uzer))
    }
    
    func getTrophies() {
        // check for persistence
        if userDict["persistence"] != nil {
            let persistence = userDict["persistence"] as! Bool
            if persistence == true {
                self.trophyPersistence.setTitle("🏋", forState: UIControlState.Normal)
            }
        }
        // check for first correct guess
        let exclude = userDict["exclude"] as! NSDictionary
        let excludeString = exclude.description
        if excludeString.rangeOfString("correct") != nil {
            self.trophyFirst.setTitle("🚼", forState: UIControlState.Normal)
        }
        // check for first submission
        if userDict["submitted"] != nil {
            self.trophyCrayon.setTitle("🖍", forState: UIControlState.Normal)
        }
        // check for 5 submissions
        if userDict["submitted"] != nil {
            let submit = userDict["submitted"] as! NSDictionary
            if submit.count >= 5 {
                self.trophyPencil.setTitle("✏️", forState: UIControlState.Normal)
            }
        }
        // check for score 100
        let score = userDict["score"] as! Int
        if score >= 100 {
            self.trophy100.setTitle("💯", forState: UIControlState.Normal)
        }
        // check for score 1000
        if score >= 1000 {
            self.trophy1000.setTitle("🏅", forState: UIControlState.Normal)
        }

        // check for first_to_be_right
        if userDict["first_to_be_right"] != nil {
            self.trophyFirstRight.setTitle("🎭", forState: UIControlState.Normal)
        }
        // check for sharing
        if userDict["shared"] != nil {
            let shared = userDict["shared"] as! Bool
            if shared == true {
                self.trophyShare.setTitle("🙌", forState: UIControlState.Normal)
            }
        }
        // check for streak5
        if userDict["streak"] != nil {
            let streak = userDict["streak"] as! Int
            if streak == 5 {
                self.trophyStreak5.setTitle("🎯", forState: UIControlState.Normal)
            }
        }
        // check for skips
        if userDict["skip"] != nil {
            let skip = userDict["skip"] as! Int
            if skip == 3 {
                self.trophySkip.setTitle("😴", forState: UIControlState.Normal)
            }
        }
        analytics.flush()
    }
    
    @IBAction func persistence(sender: AnyObject) {
        let trophyTitle = "Persistence"
        if self.trophyPersistence.titleLabel!.text == "🏋" {
            let trophy = UIAlertController(title: trophyTitle, message: "You got a movie right after more than 5 guesses!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "yes"]).userId(uzer))
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }
    
    @IBAction func firstSolve(sender: AnyObject) {
        let trophyTitle = "Learning to Crawl"
        if self.trophyFirst.titleLabel!.text == "🚼" {
            let trophy = UIAlertController(title: trophyTitle, message: "You solved your first movie!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "yes"]).userId(uzer))
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }

    @IBAction func crayon(sender: AnyObject) {
        let trophyTitle = "Author, Author"
        if self.trophyCrayon.titleLabel!.text == "🖍" {
            let trophy = UIAlertController(title: trophyTitle, message: "You submitted your first movie to Emojisodes!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "yes"]).userId(uzer))
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }
    
    @IBAction func pencil(sender: AnyObject) {
        let trophyTitle = "What's up, Scorcese?"
        if self.trophyPencil.titleLabel!.text == "✏️" {
            let trophy = UIAlertController(title: trophyTitle, message: "You submitted five movies to Emojisodes!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "yes"]).userId(uzer))
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }
    
    @IBAction func oneHundred(sender: AnyObject) {
        let trophyTitle = "Keep it 100"
        if self.trophy100.titleLabel!.text == "💯" {
            let trophy = UIAlertController(title: trophyTitle, message: "You scored 100 points!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "yes"]).userId(uzer))
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }

    @IBAction func firstRight(sender: AnyObject) {
        let trophyTitle = "Roll out the red carpet"
        if self.trophyFirstRight.titleLabel!.text == "🎭" {
            let trophy = UIAlertController(title: trophyTitle, message: "You were the first person to solve a movie!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "yes"]).userId(uzer))
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }

    @IBAction func share(sender: AnyObject) {
        let trophyTitle = "Sharing is Caring"
        if self.trophyShare.titleLabel!.text == "🙌" {
            let trophy = UIAlertController(title: trophyTitle, message: "You shared a movie with friends!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "yes"]).userId(uzer))
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }

    }
    
    
    @IBAction func streak5(sender: AnyObject) {
        let trophyTitle = "Sharpshooter"
        if self.trophyStreak5.titleLabel!.text == "🎯" {
            let trophy = UIAlertController(title: trophyTitle, message: "You solved 5 movies in a row without skips or hints!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }
  
    @IBAction func skip(sender: AnyObject) {
        let trophyTitle = "Asleep at the Wheel"
        if self.trophySkip.titleLabel!.text == "😴" {
            let trophy = UIAlertController(title: trophyTitle, message: "You skipped 3 movies in a row, you lazy bum.", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Fair Enough", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }
    
    @IBAction func oneThousand(sender: AnyObject) {
        let trophyTitle = "High Society"
        if self.trophy1000.titleLabel!.text == "🏅" {
            let trophy = UIAlertController(title: trophyTitle, message: "You racked up 1,000 points!", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Awesome", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
        } else {
            let trophy = UIAlertController(title: "🔒", message: "???", preferredStyle: UIAlertControllerStyle.Alert)
            trophy.addAction(UIAlertAction(title: "Harumph", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) in
                trophy.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(trophy, animated: true, completion: nil)
            analytics.enqueue(TrackMessageBuilder(event: "Viewed Trophy").properties(["trophy": trophyTitle, "visible": "no"]).userId(uzer))
        }
    }
    
    
    
    func getSubmittedCount() {
        userRef.child(uzer).child("submitted").observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot!) in
            var count = 0
            count += Int(snapshot.childrenCount)
            print("count of child nodes is \(count)")
            self.submittedLabel.text = String(count)
        })
    }
    
    func saveHighscore(gcScore:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            
            var scoreReporter = GKScore(leaderboardIdentifier: "grp.emojisodes")
            var gcScore = userDict["score"]! as! Int
            print("gcScore is \(gcScore)")
            scoreReporter.value = Int64(gcScore)
            var scoreArray: [GKScore] = [scoreReporter]
            print("scoreArray is \(scoreArray)")
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(NSError) -> Void in
                if NSError != nil {
                    print(NSError!.localizedDescription)
                } else {
                    print("completed Easy")
                }
            })
        }
    }
    
    func refreshUser() {
        userRef.child(uzer).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            userDict = snapshot.value! as! [String : AnyObject]
            print("userDict is \(userDict)")
        })
    }
    
    func showLeader() {
        var vc = self
        var gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc.presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }



    
}
