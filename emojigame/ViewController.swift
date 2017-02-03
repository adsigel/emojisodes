//
//  ViewController.swift
//  Fun Facts
//
//  Created by Adam Sigel on 7/7/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import UIKit
import Firebase
//import CoreFoundation
import AnalyticsSwift
import TwitterKit
import Toast_Swift

let ref = FIRDatabase.database().reference()
let movieRef = ref.child("movies")
var userGuess = String()
var movieValue: Int = 0
var excludeIndex = [String]()
var movie = [Movies]()
var movieIDArray = [String]()
var user: User!
var movieToGuess = String()
var movieID = String()
var movieDict = [String: AnyObject]()
var moviesPlayed = ""
var now = ""
var guessCount: Int = 0
var streak = 0
var skip = 0
var remember = String()
var comingBack : Bool = false

class ViewController: UIViewController, UITextFieldDelegate {

    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    var submitName = String()
    @IBOutlet weak var userGuess: UITextField!
    @IBOutlet weak var emojiPlot: UILabel!
    @IBOutlet weak var userScore: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var hintReleased: UILabel!
    @IBOutlet weak var hintDirector: UILabel!
    @IBOutlet weak var hintActors: UILabel!
    @IBOutlet weak var hintPlot: UILabel!
    @IBOutlet weak var submittedBy: UILabel!
    @IBOutlet weak var skipLabel: UILabel!
    @IBOutlet weak var suggestEdit: UIButton!
    @IBOutlet weak var bragButton: UIButton!
    @IBOutlet weak var bragLabel: UILabel!
    
    func textFieldShouldReturn(userGuess: UITextField) -> Bool {
        userGuess.resignFirstResponder()
        checkGuess()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        print("viewDidLoad initial read of userDict is \(userDict)")
        if comingBack == true {
            self.getMovieData(remember)
            self.userScore.text = String(userDict["score"]!)
            self.userScore.textColor = UIColor.init(red: 195/255, green: 247/255, blue: 58/255, alpha: 1.0)
            comingBack = false
            remember = ""
        } else {
            self.randomKeyfromFIR{ (movieToGuess) -> () in
                self.getMovieData(movieToGuess)
            }
        }
        
        self.userScore.text = String(userDict["score"]!)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func nextRound() {
        self.skipButton.setTitle("🚫", forState: UIControlState.Normal)
        self.skipLabel.text = "Skip"
        self.suggestEdit.hidden = true
        self.bragButton.hidden = true
        self.bragLabel.hidden = true
        print("User wants another movie.")
        guessCount = 0
        userGuess.text = ""
        self.hintReleased.hidden = true
        self.hintDirector.hidden = true
        self.hintActors.hidden = true
        self.hintPlot.hidden = true
        self.submitPrompt()
        self.randomKeyfromFIR{ (movieToGuess) -> () in
            self.getMovieData(movieToGuess)
        }
        analytics.flush()
    }
    
    func submitPrompt() {
        if userDict["exclude"] != nil {
            let rounds = userDict["exclude"] as! NSDictionary
            let length = rounds.count
            if length % 9 == 0 {
                let submitPrompt = UIAlertController(title: "Try Adding a Movie", message: "You've done a lot of guessing. Why not try adding a movie for other people to guess?", preferredStyle: UIAlertControllerStyle.Alert)
                let OKAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
                    print("User has chosen the benvolent path.")
                    remember = movieToGuess
                    self.performSegueWithIdentifier("AddMovie", sender: nil)
                }
                let cancelAction = UIAlertAction(title: "No Thanks", style: .Default) { (action) in
                    print("User has chosen the selfish path.")
                }
                submitPrompt.addAction(OKAction)
                submitPrompt.addAction(cancelAction)
                self.presentViewController(submitPrompt, animated: true, completion: nil)
            }
        }
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func updateProfileButton(sender: AnyObject) {
        remember = movieToGuess
        performSegueWithIdentifier("updateProfile", sender: sender)
    }
   
    func checkGuess() {
        nowStamp()
        var guess = userGuess.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guessCount = guessCount + 1
        print("User has guessed " + guess!)
        var title = movieDict["title"] as! String
        if title.hasPrefix("the ") {
            title = title.stringByReplacingOccurrencesOfString("the ", withString: "")
        }
        if guess!.hasPrefix("the ") {
            guess = guess!.stringByReplacingOccurrencesOfString("the ", withString: "")
        }
        if title.score(guess!, fuzziness: 0.9) > 0.8 {
            print("userGuess is correct")
            // update user score and count in db
            var newScore: Int = userDict["score"] as! Int
            newScore = newScore + movieValue
            userDict["score"] = newScore
            self.userScore.text = String(userDict["score"]!)
            self.userScore.textColor = UIColor.init(red: 195/255, green: 247/255, blue: 58/255, alpha: 1.0)
            let anim = CAKeyframeAnimation( keyPath:"transform" )
            anim.values = [
                NSValue( CATransform3D:CATransform3DMakeTranslation(0, 0, 0)),
                NSValue( CATransform3D:CATransform3DMakeTranslation(0, 10, 0))
            ]
            anim.autoreverses = true
            anim.repeatCount = 2
            anim.duration = 7/100
            
            self.userScore.layer.addAnimation( anim, forKey:nil )
            self.delay(2.0) {
                self.userScore.textColor = UIColor.whiteColor()
            }
            userRef.child(uzer).child("score").setValue(newScore)
            userRef.child(uzer).child("correct").setValue((userDict["correct"]! as! Int) + 1)
            // adds new child to /exclude with movie key
            userRef.child(uzer).child("exclude").child(movieToGuess).setValue("correct")
            print("adding \(movieToGuess) to user's exclude list")
            ProfileController().buildMovieList()
            analytics.enqueue(TrackMessageBuilder(event: "Guessed Movie").properties(["movie": title, "guess": guess!, "outcome": "correct"]).userId(uzer))

            // reset skip count
            skip = 0
            // track streak
            streak = streak + 1
            if streak >= 5 {
                userRef.child(uzer).child("streak").setValue(5)
            }
            // end track streak
            if guessCount > 4 {
                userRef.child(uzer).child("persistence").setValue(true)
            }
//            let guesses = movieRef.child(movieToGuess).child("guesses") as! NSDictionary
//            if guesses.count == 1 {
//                userRef.child(uzer).child("first_to_be_right").setValue(true)
//            }
            movieDict["points"] as! Int
            // hide hints
            self.hintActors.hidden = true
            self.hintReleased.hidden = true
            self.hintDirector.hidden = true
            self.hintPlot.hidden = true
            // change Skip to Next
            self.skipButton.setTitle("➡️", forState: UIControlState.Normal)
            self.skipLabel.text = "Next"
            // unhide Suggest Edit and Brag buttons
            self.suggestEdit.hidden = false
            self.bragButton.hidden = false
            self.bragLabel.hidden = false

            let message = "The movie was \(movieDict["title"]!.capitalizedString) (\(movieDict["year"]!)), directed by \(movieDict["director"]!)."
            self.view.makeToast(message, duration: 3.0, position: .Bottom, title: "You got it!", image: UIImage(named: "success.png"), style:nil) { (didTap: Bool) -> Void in
                if didTap {
                    print("completion from tap")
                    self.nextRound()
                } else {
                    print("completion without tap")
                }
            }
        } else {
            print("userGuess is incorrect")
            analytics.enqueue(TrackMessageBuilder(event: "Guessed Movie").properties(["movie": title, "guess": guess!, "outcome": "incorrect"]).userId(uzer))
            let anim = CAKeyframeAnimation( keyPath:"transform" )
            anim.values = [
                NSValue( CATransform3D:CATransform3DMakeTranslation(-10, 0, 0 ) ),
                NSValue( CATransform3D:CATransform3DMakeTranslation( 10, 0, 0 ) )
            ]
            anim.autoreverses = true
            anim.repeatCount = 2
            anim.duration = 7/100
            
            userGuess.layer.addAnimation( anim, forKey:nil )
        }
        
    }
    @IBAction func suggestEdit(sender: AnyObject) {
        print("user tapped Suggest Edit button")
        let title = movieDict["title"]!.capitalizedString
        let suggestEditController = UIAlertController(title: "Suggest an edit", message: "What should the emojisode be for \(title)?", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Suggest edit", style: .Default) { (_) in
            if let field = suggestEditController.textFields![0] as? UITextField {
                // store your data
                NSUserDefaults.standardUserDefaults().setObject(field.text, forKey: "suggestion")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.analytics.enqueue(TrackMessageBuilder(event: "Suggested Edit").properties(["title": movieDict["title"]!, "suggestion": (field.text)!]).userId(uzer))
                self.analytics.flush()
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        suggestEditController.addTextFieldWithConfigurationHandler { (textField) in
            textField.text = movieDict["plot"]! as! String
        }
        
        suggestEditController.addAction(confirmAction)
        suggestEditController.addAction(cancelAction)
        
        self.presentViewController(suggestEditController, animated: true, completion: nil)
    }
    
    @IBAction func brag(sender: AnyObject) {
        print("user tapped Brag button")
        let composer = TWTRComposer()
        let plot = movieDict["plot"]! as! String
        composer.setText("I'm playing @emojisodes and I just figured out what movie this is! \(plot)")
        
        // Called from a UIViewController
        composer.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
                self.analytics.enqueue(TrackMessageBuilder(event: "Bragged").properties(["movie": movieDict["title"]!, "outcome": "fail", "place": "guessRight"]).userId(uzer))
                self.analytics.flush()
//                self.nextRound()
            }
            else {
                print("Sending tweet!")
                self.analytics.enqueue(TrackMessageBuilder(event: "Bragged").properties(["movie": movieDict["title"]!, "outcome": "success", "place": "guessRight"]).userId(uzer))
                self.analytics.flush()
                self.nextRound()
            }
        }
    }
    
    @IBAction func hintButton(sender: AnyObject) {
        print("User has asked for a hint.")
        var hintCategory = ""
        if movieDict["year"]! as! String == "" {
//             year hint is empty, there are no hints
            let hintErrorAlert = UIAlertController(title: "No hints found", message: "Uh oh! Looks like this movie doesn't have any hints. How about a free \(movieDict["points"]!) points?", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "Take \(movieDict["points"]!) points", style: .Default) { (action) in
                self.userGuess.text = ""
                var newScore: Int = userDict["score"] as! Int
                newScore = newScore + movieValue
                userDict["score"] = newScore
                self.userScore.text = String(userDict["score"]!)
                self.userScore.textColor = UIColor.init(red: 195/255, green: 247/255, blue: 58/255, alpha: 1.0)
                let anim = CAKeyframeAnimation( keyPath:"transform" )
                anim.values = [
                    NSValue( CATransform3D:CATransform3DMakeTranslation(0, 0, 0)),
                    NSValue( CATransform3D:CATransform3DMakeTranslation(0, 10, 0))
                ]
                anim.autoreverses = true
                anim.repeatCount = 2
                anim.duration = 7/100
                
                self.userScore.layer.addAnimation( anim, forKey:nil )
                self.delay(2.0) {
                    self.userScore.textColor = UIColor.whiteColor()
                }
                userRef.child(uzer).child("score").setValue(newScore)
                self.analytics.enqueue(TrackMessageBuilder(event: "Hint Error").properties(["movie":movieDict["title"]!, "points taken": "yes"]).userId(uzer))
                self.analytics.flush()
                self.nextRound()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                print("User has chosen to continue hintless.")
                self.analytics.enqueue(TrackMessageBuilder(event: "Hint Error").properties(["movie":movieDict["title"]!, "points taken": "no"]).userId(uzer))
                self.analytics.flush()
            }
            hintErrorAlert.addAction(OKAction)
            hintErrorAlert.addAction(cancelAction)
            self.presentViewController(hintErrorAlert, animated: true, completion: nil)
        } else {
            hintIf: if self.hintReleased.hidden == true {
                let hint = movieDict["year"] as! String
                hintCategory = "year"
                self.hintReleased.text = "Released: \(hint)"
                self.hintReleased.hidden = false
                var newScore: Int = userDict["score"] as! Int
                newScore = newScore - 10
                userDict["score"] = newScore
                self.userScore.text = String(userDict["score"]!)
                self.userScore.textColor = UIColor.init(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
                self.delay(2.0) {
                    self.userScore.textColor = UIColor.whiteColor()
                }

                streak = 0
                break hintIf
            } else {
                if self.hintDirector.hidden == true {
                    let hint = movieDict["director"] as! String
                    hintCategory = "director"
                    self.hintDirector.text = "Directed by: \(hint)"
                    self.hintDirector.hidden = false
                    var newScore: Int = userDict["score"] as! Int
                    newScore = newScore - 10
                    userDict["score"] = newScore
                    self.userScore.text = String(userDict["score"]!)
                    self.userScore.textColor = UIColor.init(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
                    self.delay(2.0) {
                        self.userScore.textColor = UIColor.whiteColor()
                    }
                    streak = 0
                    break hintIf
                } else {
                    if self.hintActors.hidden == true {
                        let hint = movieDict["actors"] as! String
                        hintCategory = "actors"
                        self.hintActors.text = "Starring: \(hint)"
                        self.hintActors.hidden = false
                        var newScore: Int = userDict["score"] as! Int
                        newScore = newScore - 10
                        userDict["score"] = newScore
                        self.userScore.text = String(userDict["score"]!)
                        self.userScore.textColor = UIColor.init(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
                        self.delay(2.0) {
                            self.userScore.textColor = UIColor.whiteColor()
                        }
                        streak = 0
                        break hintIf
                    } else {
                        if self.hintPlot.hidden == true {
                            let hint = movieDict["OMDBplot"] as! String
                            hintCategory = "plot"
                            self.hintPlot.text = "Plot: \(hint)"
                            self.hintPlot.hidden = false
                            var newScore: Int = userDict["score"] as! Int
                            newScore = newScore - 10
                            userDict["score"] = newScore
                            self.userScore.text = String(userDict["score"]!)
                            self.userScore.textColor = UIColor.init(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
                            self.delay(2.0) {
                                self.userScore.textColor = UIColor.whiteColor()
                            }
                            streak = 0
                            break hintIf
                        }
                    }
                }
            }
            analytics.enqueue(TrackMessageBuilder(event: "Hint Requested").properties(["category": hintCategory, "movie":movieDict["title"]!]).userId(uzer))
        }
    }
    
    @IBAction func skipMovie(sender: AnyObject) {
        if self.skipLabel.text == "Next" {
            self.nextRound()
        } else {
            let skipAlert = UIAlertController(title: "Skip this movie?", message: "You can skip this for now, but it'll cost you 25 points. Are you sure you want to skip?", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "I'm sure", style: .Default) { (action) in
                self.nowStamp()
                streak = 0
                skip = skip + 1
                if skip >= 3 {
                    userRef.child(uzer).child("skip").setValue(3)
                }
                print("User has chosen the coward's way out.")
                self.userGuess.text = ""
                var newScore: Int = userDict["score"] as! Int
                newScore = newScore - 25
                userDict["score"] = newScore
                self.userScore.text = String(userDict["score"]!)
                self.userScore.textColor = UIColor.init(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
                self.delay(2.0) {
                    self.userScore.textColor = UIColor.whiteColor()
                }
                userRef.child(uzer).child("score").setValue(newScore)
                self.analytics.enqueue(TrackMessageBuilder(event: "Skipped Movie").properties(["movie":movieDict["title"]!]).userId(uzer))
                self.nextRound()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                print("User has chosen to press on bravely.")
            }
            skipAlert.addAction(OKAction)
            skipAlert.addAction(cancelAction)
            self.presentViewController(skipAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        let textToShare = "I'm playing @emojisodes. Help me guess what movie this is! " + (movieDict["plot"]! as! String)
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as! UIView
        self.presentViewController(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            if completed == true {
                self.analytics.enqueue(TrackMessageBuilder(event: "Shared Movie").properties(["movie": movieDict["title"]!, "outcome": "success"]).userId(uzer))
                self.analytics.flush()
            } else {
                self.analytics.enqueue(TrackMessageBuilder(event: "Shared Movie").properties(["movie": movieDict["title"]!, "outcome": "fail"]).userId(uzer))
                self.analytics.flush()
            }
        }
    }
    
    @IBAction func newRoundButton(sender: AnyObject) {
        self.nextRound()
    }
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        
    }
    
    @IBAction func addMovie(sender: AnyObject) {
        remember = movieToGuess
        analytics.enqueue(TrackMessageBuilder(event: "Viewed Add Movie Screen").userId(uzer))
        analytics.flush()
        performSegueWithIdentifier("AddMovie", sender: sender)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    
    func randomKeyfromFIR (completion:String -> ()) {
        var movieCount = 0
        movieIDArray = []
        userRef.child(uzer).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            userDict = snapshot.value! as! [String : AnyObject]
            print("in randomKeyfromFIR userDict is... \(userDict)")
        })
        movieRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for item in snapshot.children {
                let movieItem = Movies(snapshot: item as! FIRDataSnapshot)
                movieID = movieItem.key!
                let approved = movieItem.approved
                if approved == 1 {
                    movieIDArray.append(movieID)
                    movieCount = Int(movieIDArray.count)
                }
            }
            print("The number of approved movies is \(movieCount)")
            var randomIndex : Int = 0
            let moviePlayed = userDict["exclude"] as! [String:AnyObject]
            print("Here is moviePlayed: \(moviePlayed)")
            let moviePlayedKeys = Array(moviePlayed.keys)
            print("Here is moviePlayedKeys: \(moviePlayedKeys)")
            if moviePlayedKeys.count == movieCount {
                let allDone = UIAlertController(title: "A Winner Is You", message: "You've gone through all the emojisodes. Go contribute your own and keep the game going!", preferredStyle: UIAlertControllerStyle.Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    print("User acknowledges their champion status.")
                    let url = NSURL(string: "https://twitter.com/emojisodes")!
                    UIApplication.sharedApplication().openURL(url)
                    }
                allDone.addAction(OKAction)
                self.presentViewController(allDone, animated: true, completion: nil)
            }
            // Check to see if user has played that movie before
            repeat {
                randomIndex = Int(arc4random_uniform(UInt32(movieCount)))
                print("randomIndex is \(randomIndex)")
                movieToGuess = movieIDArray[randomIndex]
                print("checking to see if key \(movieToGuess) has already been played...")
            } while moviePlayedKeys.contains(movieToGuess)
            print("movie to guess is \(movieToGuess)")
            completion(movieToGuess)

            })
    }
    
    func getMovieData(movieToGuess:String) {
        let movieToGuessRef = movieRef.ref.child(movieToGuess)
        movieToGuessRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            movieDict = snapshot.value as! [String : AnyObject]
            if movieDict["plot"] != nil {
                let plot = movieDict["plot"]! as! String
                print("plot is \(plot)")
                self.emojiPlot.text = plot
            }
            let submitID = movieDict["addedByUser"] as! String
            userRef.child(submitID).child("name").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                // todo: catch null values here to avoid crash
                self.submitName = snapshot.value! as! String
                self.submittedBy.text = "Submitted by: \(self.submitName)"
            })
            movieValue = movieDict["points"] as! Int
        })
        
    }
    
    func nowStamp() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateformatter.timeStyle = NSDateFormatterStyle.LongStyle
        now = dateformatter.stringFromDate(NSDate())
    }
    
}

