//
//  LoginController.swift
//  emojigame
//
//  Created by Adam Sigel on 8/10/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//
//  TODO
//  * Use user.uid to get child values (e.g. score) for currentUser
//  * Email verification
//  * Confirm sign out
//  * Confirm new user added to db every time
//  * Intro screen

import UIKit
import Foundation
import Firebase
import GameKit
import AnalyticsSwift

var userDict = [String:AnyObject]()
var uzer = ""
let userRef = ref.child("users")
var newUser = String()
var gcAuth : Bool = false
var alias = ""
var defaults = NSUserDefaults(suiteName: "group.com.adamdsigel.emojisodes")

class LoginController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, GKGameCenterControllerDelegate {
    
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

   
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.hidden = true
        self.authenticateLocalPlayer{ (uzer) -> () in
            self.addToFirebase(uzer)
        }
        analytics.enqueue(TrackMessageBuilder(event: "Game Loaded").userId(uzer))
    }
    
    @IBAction func playButton(sender: AnyObject) {
        let newUserRef = userRef.child(uzer)
        analytics.enqueue(TrackMessageBuilder(event: "Pressed Play").userId(uzer))
        self.currentDate()
        print("Is this a new user? \(newUser)")
        if newUser == "false" {
            // user has been here before
            print("This user has been here before.")
            newUserRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                userDict = snapshot.value! as! [String : AnyObject]
                print("userDict is \(userDict)")
            })
            lastLogin()
            delay(1.0) {
//                var defaults = NSUserDefaults(suiteName: "group.com.emojisodes")
//                defaults?.setObject(userDict, forKey: "userDict")
//                defaults?.synchronize()
                self.performSegueWithIdentifier("logIn", sender: sender)
                self.analytics.flush()
            }
        } else {
            userDict = ["name": alias, "email": "", "score": 0, "correct": 0, "addedDate": dateString, "exclude": ["key": true], "new_in_town": "true"]
            print("userDict is \(userDict)")
            newUserRef.setValue(userDict)
            analytics.enqueue(TrackMessageBuilder(event: "New User").userId(uzer))
            self.performSegueWithIdentifier("firstTime", sender: sender)
            analytics.flush()
        }
        
    }

    
    func currentDate() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateformatter.timeStyle = NSDateFormatterStyle.LongStyle
        dateString = dateformatter.stringFromDate(NSDate())
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func authenticateLocalPlayer(completion:String -> ()) {
        var localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
                print("User is not signed into Game Center")
                gcAuth = false
                print("gcAuth is \(gcAuth)")
                uzer = UIDevice.currentDevice().identifierForVendor!.UUIDString
                alias = ""
                print("uzer is \(uzer)")
                defaults?.setObject(uzer, forKey: "extensionUzer")
                print("synchronizing extensionUzer as \(uzer)")
            } else {
                print((GKLocalPlayer.localPlayer().authenticated))
                gcAuth = true
                print("gcAuth is \(gcAuth)")
                print("localPlayer is: \(localPlayer)")
                if let playerUnwrapped = localPlayer.playerID {
                    uzer = localPlayer.playerID!
                } else {
                    uzer = UIDevice.currentDevice().identifierForVendor!.UUIDString
                }
                if let aliasUnwrapped = localPlayer.alias {
                    alias = localPlayer.alias!
                }
                print("uzer is \(uzer)")
                defaults?.setObject(uzer, forKey: "extensionUzer")
                print("synchronizing extensionUzer as \(uzer)")
            }
            completion(uzer)
        }
    }
    
    func addToFirebase(uzer:String) {
//        let dummyDict = ["dummy": "dummy"]
        let newUserRef = userRef.child(uzer)
        newUserRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            print(snapshot.value!)
            if snapshot.hasChildren() {
                print("There is data here. This user has been here before.")
                newUser = "false"
            } else {
                print("No chidren at this snapshot location. This is a new user.")
                newUser = "true"
            }
            self.playButton.hidden = false
            self.spinner.hidden = true
        })
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func lastLogin() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateformatter.timeStyle = NSDateFormatterStyle.LongStyle
        let lastLoginStamp = dateformatter.stringFromDate(NSDate())
        userRef.child(uzer).child("last-login").setValue(lastLoginStamp)
    }

    
}
