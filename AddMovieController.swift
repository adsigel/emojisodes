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
import Toast_Swift

var dateString = ""
var uid = ""
var result = [String: String]()
var lowercasedTitles = [String]()
var bountyTitles = [String]()
var bountyDict = [String: AnyObject]()
var allMovies = [String: AnyObject]()
var points : Int = 0
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
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet weak var titleError: UILabel!
    @IBOutlet weak var userSubmitTitle: UITextField!
    @IBOutlet weak var userSubmitPlot: UITextField!
    @IBOutlet weak var checkMovie: UIButton!
    @IBOutlet weak var addMovie: UIButton!
    @IBOutlet weak var addAgain: UIButton!
    @IBOutlet weak var bountyButton: UIButton!
    
    
    // Lazy Stored Property
    lazy var apiController: OMDBAPIController = OMDBAPIController(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        addMovie.userInteractionEnabled = false
        addMovie.alpha = 0.25
        apiController.delegate = self
    }
    
    @IBAction func addAnother(sender: AnyObject) {
        self.userSubmitPlot.text = ""
        self.userSubmitTitle.text = ""
        self.userSubmitTitle.becomeFirstResponder()
        self.addAgain.hidden = true
        self.userSubmitTitle.layer.borderWidth = 0
        analytics.enqueue(TrackMessageBuilder(event: "Tapped Add Another").userId(uzer))
        analytics.flush()
    }
    
    @IBAction func goBackButton(sender: AnyObject) {
        comingBack = true
        analytics.enqueue(TrackMessageBuilder(event: "Dismissed Add Movie Screen").userId(uzer))
        analytics.flush()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func checkMovie(sender: AnyObject) {
        // check to make sure there are no emoji in the title
        if userSubmitTitle.text! == "" {
            self.view.makeToast("Please enter a movie title", duration: 3.0, position: CGPoint(x: screenSize.width/2, y:screenSize.height/2))
            analytics.enqueue(TrackMessageBuilder(event: "Submission Error").properties(["error with": "title", "error": "empty field"]).userId(uzer))
            analytics.flush()
        } else {
            apiController.searchOMDB(userSubmitTitle.text!)
        }
    }
    // Bounty Func
    // 1. Pick a movie at random from /bounty - DONE
    // 2. Check to see if it's already in /movies - DONE
    // 3. If not already in the game, plug title in to userSubmitTitle and check movie
    // 4. When user submits, apply bounty value to score.
    // 5. Add Segment events
    @IBAction func claimBounty(sender: AnyObject) {
        let bountyRef = ref.child("bounty")
        // get all titles in the game
        movieRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for item in snapshot.children {
                let movieItem = Movies(snapshot: item as! FIRDataSnapshot)
                let movieTitle = movieItem.title!
                movieTitles.append(movieItem.title.capitalizedString)
                print("movieTitles is \(movieTitles)")
            }
//            allMovies = snapshot.value as! [String:AnyObject]
        })
        // get all the titles at bounty endpoint, compare to the titles in the game
        bountyRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            bountyDict = snapshot.value! as! [String : AnyObject]
            print("bountyDict is \(bountyDict)")
            bountyTitles = Array(bountyDict.keys)
            print("bountyTitles is \(bountyTitles)")
            for item in bountyTitles {
                if movieTitles.contains(item) {
                    print("\(item) has been found in movieTitles, removing from list")
                    var indexOfItem = bountyTitles.indexOf(item)
                    bountyTitles.removeAtIndex(indexOfItem!)
                }
            }
            print("bountyTitles is now \(bountyTitles) and the count is \(bountyTitles.count)")
            // pick a random one
            var randomTitle = Int(arc4random_uniform(UInt32(bountyTitles.count)))
            print("randomTitle is \(bountyTitles[randomTitle])")
            var bounty = bountyTitles[randomTitle]
            // show bounty title to user
            let pointsString = bountyDict[bounty]!
            let bountyPrompt = UIAlertController(title: "Earn \(pointsString) points", message: "Do you want to add an emojisode for \(bounty)?", preferredStyle: UIAlertControllerStyle.Alert)
            let okay = UIAlertAction(title: "Yes", style: .Default) { (action) in
                print("User selects Yes")
                self.apiController.searchOMDB(bounty)
                self.userSubmitTitle.text = bounty
                self.userSubmitTitle.becomeFirstResponder()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                print("User selects Cancel")
            }
            bountyPrompt.addAction(okay)
            bountyPrompt.addAction(cancel)
            self.presentViewController(bountyPrompt, animated: true, completion: nil)

        })

    }

    
    @IBAction func inspireMe(sender: AnyObject) {
        let emojiArray = ["👨‍🔬", "👸", "👮‍♀️", "🕵️", "👶", "👰", "🚔", "🤢", "🗽", "🏙", "🤓", "✈️", "🏦"]
        var randomEmoji = Int(arc4random_uniform(UInt32(emojiArray.count)))
        var randEmoji = emojiArray[randomEmoji]
        
        let messageArray = [
            "What is the last movie you watched with friends?",
            "Who is your favorite actress?",
            "What's the last movie you watched at home?",
            "What's a guilty pleasure movie people don't know you like?",
            "Which movie makes you laugh hardest?",
            "What's a movie you like that takes place in another country?",
            "What's a movie that has an animal in it?",
            "What's a movie that has a \(randEmoji) in it?",
            "What's a movie that has a \(randEmoji) in it?",
            "What's a movie that has a \(randEmoji) in it?"
            ]
        
        var random = Int(arc4random_uniform(UInt32(messageArray.count)))
        var message = messageArray[random]

        let inspireMe = UIAlertController(title: "Think of a movie", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okay = UIAlertAction(title: "Dismiss", style: .Default) { (action) in
        
        }
        inspireMe.addAction(okay)
        analytics.enqueue(TrackMessageBuilder(event: "Asked for Inspiration").properties(["message": message]).userId(uzer))
        analytics.flush()
        self.presentViewController(inspireMe, animated: true, completion: nil)
    }
    
    @IBAction func userSubmitMovie (_ sender: UIButton) {
        self.currentDate()
        let characterSetNotAllowed = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyz")
        let userTitle = userSubmitTitle.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let userPlot = userSubmitPlot.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (userPlot!.rangeOfCharacterFromSet(characterSetNotAllowed) != nil) {
            self.view.makeToast("Please use emoji only for the plot", duration: 3.0, position: CGPoint(x: screenSize.width/2, y:screenSize.height/2))
            self.analytics.enqueue(TrackMessageBuilder(event: "Submission Error").properties(["error with": "plot", "error": "text"]).userId(uzer))
            analytics.flush()
        } else if userSubmitPlot.text!.characters.count == 0 {
            self.view.makeToast("I think you've lost the plot...", duration: 3.0, position: CGPoint(x: screenSize.width/2, y: screenSize.height/2))
            self.analytics.enqueue(TrackMessageBuilder(event: "Submission Error").properties(["error with": "plot", "error": "empty field"]).userId(uzer))
            analytics.flush()
        } else if 1 ... 4 ~= userSubmitPlot!.text!.characters.count {
            self.view.makeToast("Please use at least 5 emoji", duration: 3.0, position: CGPoint(x: screenSize.width/2, y:screenSize.height/2))
            analytics.enqueue(TrackMessageBuilder(event: "Submission Error").properties(["error with": "plot", "error": "length"]).userId(uzer))
            analytics.flush()
        } else if userTitle != "" && userPlot != "" {
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
            self.analytics.enqueue(TrackMessageBuilder(event: "Submitted Movie").properties(["title": userSubmitTitle.text!, "plot": userSubmitPlot.text!]).userId(uzer))
            analytics.flush()
            // update score
            var newScore: Int = userDict["score"] as! Int
            // check to see if it's a bounty movie
            let checkTitle = userTitle?.capitalizedString
            if bountyTitles.contains(checkTitle!) {
                points = bountyDict[checkTitle!] as! Int
            } else {
                points = 500
            }
            newScore = newScore + points
            userDict["score"] = newScore
            userRef.child(uzer).child("score").setValue(newScore)
            print("The new movie has been added with an id of: \(movieId)")
            var style = ToastStyle()
            var color = UIColor( red: 195/255, green: 257/255, blue: 58/255, alpha: 1.0 )
            style.messageColor = color
            // update to make placement dynamic to screen size
            self.view.makeToast("Your 🎬 has been added. You just earned \(points) points!", duration: 3.0, position: CGPoint(x: screenSize.width/2, y:screenSize.height/2), style: style)
            dismissKeyboard()
            self.addAgain.hidden = false
            self.userSubmitTitle.layer.borderWidth = 0
        }
    }

    @IBAction func editTitle(sender: AnyObject) {
        self.userSubmitTitle.layer.borderWidth = 0
        self.addMovie.userInteractionEnabled = false
        self.addMovie.alpha = 0.25
        foundYear = ""
        foundDirector = ""
        foundGenre = ""
        foundPlot = ""
        foundActors = ""
    }
    
    @IBAction func addMovieHelp(sender: AnyObject) {
        let helpAlert = UIAlertController(title: "Enabling the Emoji Keyboard", message: "You must have the emoji keyboard enabled to submit a plot. Do you need help with that?", preferredStyle: UIAlertControllerStyle.Alert)
        let good = UIAlertAction(title: "I'm good", style: .Default) { (action) in
            print("User claims to know how emoji work.")
        }
        let help = UIAlertAction(title: "Help me", style: .Default) { (action) in
            let url = NSURL(string: "https://emojisodes.com/help/#keyboard")!
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
            self.view.makeToast("Please use emoji only for the plot", duration: 3.0, position: CGPoint(x: screenSize.width/2, y:screenSize.height - 80))
        } else if userPlot == "" {
            self.view.makeToast("You can't share what doesn't exist...", duration: 3.0, position: CGPoint(x: screenSize.width/2, y:screenSize.height - 80))
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
                self.userSubmitTitle.layer.borderWidth = 2
                self.userSubmitTitle.layer.borderColor = UIColor( red: 195/255, green: 257/255, blue: 58/255, alpha: 1.0 ).CGColor
                self.userSubmitTitle.layer.cornerRadius = 6
                self.userSubmitTitle.layer.masksToBounds = true
                self.addMovie.userInteractionEnabled = true
                self.addMovie.alpha = 1
                self.analytics.enqueue(TrackMessageBuilder(event: "Checked Movie").properties(["title": self.userSubmitTitle.text!, "outcome": "confirmed"]).userId(uzer))
                self.analytics.flush()
            }
            let no = UIAlertAction(title: "No", style: .Default) { (action) in
                // this causes a crash, found nil while unwrapping an Optional
                self.titleError.hidden = false
                self.userSubmitTitle.becomeFirstResponder()
                self.userSubmitTitle.selectedTextRange = self.userSubmitTitle.textRangeFromPosition(self.userSubmitTitle.beginningOfDocument, toPosition: self.userSubmitTitle.endOfDocument)
                foundYear = ""
                foundDirector = ""
                foundGenre = ""
                foundPlot = ""
                foundActors = ""
                self.analytics.enqueue(TrackMessageBuilder(event: "Checked Movie").properties(["title": self.userSubmitTitle.text!, "outcome": "rejected"]).userId(uzer))
                self.analytics.flush()
            }
            omdbAlert.addAction(no)
            omdbAlert.addAction(yes)
            self.presentViewController(omdbAlert, animated: true, completion: nil)
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
