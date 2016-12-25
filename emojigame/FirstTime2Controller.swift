//
//  FirstTime2Controller.swift
//  emojigame
//
//  Created by Adam Sigel on 8/24/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AnalyticsSwift

class FirstTime2Controller: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var helpYear: UILabel!
    @IBOutlet weak var helpDirector: UILabel!
    @IBOutlet weak var helpActors: UILabel!
    @IBOutlet weak var helpPlot: UILabel!
    
    
    func textFieldShouldReturn(_ guessTextField: UITextField!) -> Bool {
        guessTextField.resignFirstResponder()
        checkGuess()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func goToNext(sender: AnyObject) {
        performSegueWithIdentifier("readyToPlay", sender: sender)
    }
    
    @IBAction func userHelpButton(sender: AnyObject) {
        hintIf: if self.helpYear.hidden == true {
            self.helpYear.text = "Released: 1997"
            self.helpYear.hidden = false
            self.analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Hint 1").userId(uzer))
            break hintIf
        } else {
            if self.helpDirector.hidden == true {
                self.helpDirector.text = "Directed by: James Cameron"
                self.helpDirector.hidden = false
                self.analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Hint 2").userId(uzer))
                break hintIf
            } else {
                if self.helpActors.hidden == true {
                    self.helpActors.text = "Starring: Leonardo DiCaprio, Kate Winslet, Billy Zane, Kathy Bates"
                    self.helpActors.hidden = false
                    self.analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Hint 3").userId(uzer))
                    break hintIf
                } else {
                    if self.helpPlot.hidden == true {
                        self.helpPlot.text = "Plot: A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic."
                        self.helpPlot.hidden = false
                        self.analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Hint 4").userId(uzer))
                        break hintIf
                    }
                }
            }
        }

    }
    
    
    @IBAction func checkGuess() {
        let guess = guessTextField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if guess == "titanic" {
            let guessRightAlert = UIAlertController(title: "You got it!", message: "You're ready to play Emojisodes now!", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "Let's do it", style: .Default) { (action) in
                userRef.child(uzer).child("new_in_town").setValue("false")
                self.analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Guess").properties(["outcome": "correct"]).userId(uzer))
                self.analytics.flush()
                self.goToNext(UIButton)
            }
            guessRightAlert.addAction(OKAction)
            self.presentViewController(guessRightAlert, animated: true, completion: nil)
        } else {
            let anim = CAKeyframeAnimation( keyPath:"transform" )
            anim.values = [
                NSValue( CATransform3D:CATransform3DMakeTranslation(-10, 0, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 10, 0, 0 ) )
            ]
            anim.autoreverses = true
            anim.repeatCount = 2
            anim.duration = 7/100
            
            guessTextField.layer.addAnimation( anim, forKey:nil )
            self.analytics.enqueue(TrackMessageBuilder(event: "Onboarding: Guess").properties(["outcome": "incorrect"]).userId(uzer))
        }
        
    }

    
    
}
