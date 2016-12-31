//
//  AddMovieController.swift
//  emojigame
//
//  Created by Adam Sigel on 8/3/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import Firebase
import AnalyticsSwift

var dateString = ""
var uid = ""
var result = [String: String]()
var foundActors = ""
var foundTitle = ""
var foundAwards = ""
var foundBox = ""
var foundDirector = ""
var foundGenre = ""
var foundPlot = ""
var foundYear = ""

class AddMovieController: UIViewController, UITextFieldDelegate, OMDBAPIControllerDelegate {

    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    @IBOutlet weak var titleError: UILabel!
    @IBOutlet weak var userSubmitTitle: UITextField!
    @IBOutlet weak var userSubmitPlot: UITextField!
    @IBOutlet weak var userSubmitMovieButton: UIButton!
    
    // Lazy Stored Property
    lazy var apiController: OMDBAPIController = OMDBAPIController(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        apiController.delegate = self
        analytics.enqueue(TrackMessageBuilder(event: "Viewed Add Movie Screen").properties(["title": userSubmitTitle.text!, "plot": userSubmitPlot.text!]).userId(uzer))
        userSubmitTitle.addTarget(self, action: "textFieldDidEndEditing:", forControlEvents: UIControlEvents.EditingDidEnd)
    }
    
    @IBAction func goBackButton(sender: AnyObject) {
        comingBack = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidEndEditing(userSubmitPlot: UITextField) {
        if userSubmitPlot.text! != "" {
            apiController.searchOMDB(userSubmitPlot.text!)
        }
    }
    
    @IBAction func userSubmitMovie (_ sender: AnyObject) {
        self.currentDate()
        let userTitle = userSubmitTitle.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let userPlot = userSubmitPlot.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let characterSetNotAllowed = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz")
        if userPlot!.rangeOfCharacterFromSet(characterSetNotAllowed) != nil {
            // plot has actual letters, not cool
            let lettersInPlot = UIAlertController(title: "No Letters Allowed", message: "You can't use letters in your movie plot. Emoji only please. 🙏", preferredStyle: UIAlertControllerStyle.Alert)
            let okay = UIAlertAction(title: "My bad", style: .Default) { (action) in
                self.userSubmitPlot.becomeFirstResponder()
                self.userSubmitPlot.selectedTextRange = self.userSubmitPlot.textRangeFromPosition(self.userSubmitPlot.beginningOfDocument, toPosition: self.userSubmitPlot.endOfDocument)
            }
            lettersInPlot.addAction(okay)
            self.presentViewController(lettersInPlot, animated: true, completion: nil)
        } else {
            if userTitle != "" && userPlot != "" {
                apiController.searchOMDB(userSubmitTitle.text!)
                let movieData = Movies(title: userTitle!, plot: userPlot!, hint: "", addedDate: dateString, addedByUser: uzer, approved: 1, points: 100)
                let refMovies = ref.child("movies/")
                let moviePlotRef = refMovies.childByAutoId()
                moviePlotRef.setValue(movieData.toAnyObject())
                moviePlotRef.child("actors").setValue(foundActors)
                moviePlotRef.child("OMDBplot").setValue(foundPlot)
                moviePlotRef.child("director").setValue(foundDirector)
                moviePlotRef.child("genre").setValue(foundGenre)
                moviePlotRef.child("boxoffice").setValue(foundBox)
                moviePlotRef.child("year").setValue(foundYear)
                var movieId = moviePlotRef.key
                userRef.child(uzer).child("submitted/").child(movieId).setValue(dateString)
                analytics.enqueue(TrackMessageBuilder(event: "Submitted Movie").properties(["title": userSubmitTitle.text!, "plot": userSubmitPlot.text!]).userId(uzer))
                analytics.flush()
                var newScore: Int = userDict["score"] as! Int
                newScore = newScore + 500
                userDict["score"] = newScore
                userRef.child(uzer).child("score").setValue(newScore)
                print("The new movie has been added with an id of: \(movieId)")
                // TODO: Prompt to share the newly added movie, and track this.
                let submitOkay = UIAlertController(title: "Success", message: "Your movie has been added to Emojisodes!", preferredStyle: UIAlertControllerStyle.Alert)
                let nextRound = UIAlertAction(title: "Next Round", style: .Default) { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                let addAnother = UIAlertAction(title: "Add Another", style: .Default) { (action) in
                    self.userSubmitPlot.text = ""
                    self.userSubmitTitle.text = ""
                    self.userSubmitTitle.becomeFirstResponder()
                }
                submitOkay.addAction(nextRound)
                submitOkay.addAction(addAnother)
                self.presentViewController(submitOkay, animated: true, completion: nil)
            } else {
                let badSubmitAlert = UIAlertController(title: "Something's Missing", message: "Erm, you need to provide a movie title and a plot for us to review.", preferredStyle: UIAlertControllerStyle.Alert)
                badSubmitAlert.addAction(UIAlertAction(title: "Gotcha", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(badSubmitAlert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addMovieHelp(sender: AnyObject) {
        let helpAlert = UIAlertController(title: "Enabling the Emoji Keyboard", message: "You must have the emoji keyboard enabled to submit a plot. Do you need help with that?", preferredStyle: UIAlertControllerStyle.Alert)
        let good = UIAlertAction(title: "I'm good", style: .Default) { (action) in
            print("User claims to know how emoji work.")
        }
        let help = UIAlertAction(title: "Help me", style: .Default) { (action) in
            let url = NSURL(string: "http://emojisodes.com/help")!
            UIApplication.sharedApplication().openURL(url)

        }
        helpAlert.addAction(good)
        helpAlert.addAction(help)
        analytics.enqueue(TrackMessageBuilder(event: "Add Movie Help").userId(uzer))
        self.presentViewController(helpAlert, animated: true, completion: nil)
    }
    
    @IBAction func shareWithFriends(sender: AnyObject) {
        let userPlot = userSubmitPlot.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let characterSetNotAllowed = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz")
        if userPlot!.rangeOfCharacterFromSet(characterSetNotAllowed) != nil {
            // plot has actual letters, not cool
            let lettersInPlot = UIAlertController(title: "No Letters Allowed", message: "You can't use letters in your movie plot. Emoji only please. 🙏", preferredStyle: UIAlertControllerStyle.Alert)
            let okay = UIAlertAction(title: "My bad", style: .Default) { (action) in
                self.userSubmitPlot.becomeFirstResponder()
                self.userSubmitPlot.selectedTextRange = self.userSubmitPlot.textRangeFromPosition(self.userSubmitPlot.beginningOfDocument, toPosition: self.userSubmitPlot.endOfDocument)
            }
            lettersInPlot.addAction(okay)
            self.presentViewController(lettersInPlot, animated: true, completion: nil)
        } else if userPlot == "" {
            let badSubmitAlert = UIAlertController(title: "Something's Missing", message: "Erm, you need to provide a movie plot to share with friends.", preferredStyle: UIAlertControllerStyle.Alert)
            badSubmitAlert.addAction(UIAlertAction(title: "Gotcha", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(badSubmitAlert, animated: true, completion: nil)
        } else {
            let textToShare = "I'm playing Emojisodes 🎬. What do you think of this new movie I want to add? \(userPlot!)"
            let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sender as! UIView
            self.presentViewController(activityVC, animated: true, completion: nil)
            activityVC.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]
            activityVC.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                //technically only checks if user presses Cancel at share sheet level, not tweet level
                print("Shared video activity: \(activityType)")
                self.analytics.enqueue(TrackMessageBuilder(event: "Shared Submission").properties(["title": self.userSubmitTitle.text!, "plot": self.userSubmitPlot.text!]).userId(uzer))
            }
        }
        analytics.flush()
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func currentDate() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateformatter.timeStyle = NSDateFormatterStyle.LongStyle
        dateString = dateformatter.stringFromDate(NSDate())
    }
    
    func didFinishOMDBSearch(result: Dictionary<String, String>) {
        
        if let year = result["Year"], let title = result["Title"] {
            let omdbAlert = UIAlertController(title: "Confirm Your Movie", message: "Are you referring to the movie \(title) released in \(year)?", preferredStyle: UIAlertControllerStyle.Alert)
            let yes = UIAlertAction(title: "Yes", style: .Default) { (action) in
                print("User has confirmed the movie metadata.")
                foundYear = result["Year"]!
                foundDirector = result["Director"]!
                foundGenre = result["Genre"]!
                foundBox = result["BoxOffice"]!
                foundPlot = result["Plot"]!
                foundActors = result["Actors"]!
            }
            let no = UIAlertAction(title: "No", style: .Default) { (action) in
                self.titleError.hidden = false
            }
            omdbAlert.addAction(no)
            omdbAlert.addAction(yes)
            self.presentViewController(omdbAlert, animated: true, completion: nil)
        } else {
            print("Could not find movie")
            let badResult = UIAlertController(title: "No Movie Found", message: "Sorry, we couldn't find any movies with that title. Try another movie.", preferredStyle: UIAlertControllerStyle.Alert)
            let okay = UIAlertAction(title: "Okay", style: .Default) { (action) in
                self.userSubmitTitle.becomeFirstResponder()
                self.userSubmitTitle.selectedTextRange = self.userSubmitTitle.textRangeFromPosition(self.userSubmitTitle.beginningOfDocument, toPosition: self.userSubmitTitle.endOfDocument)
            }
            badResult.addAction(okay)
            self.presentViewController(badResult, animated: true, completion: nil)
        }
        
        if let foundActors = result["Actors"] {
            print("Starring \(foundActors)")
        }
        
        if let foundGenre = result["Genre"] {
            print("Categorized as \(foundGenre)")
        } else {
            print("Could not find genres")
        }
        
    }
    
}
