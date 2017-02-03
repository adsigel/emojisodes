//
//  MovieListController.swift
//  emojigame
//
//  Created by Adam Sigel on 12/13/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AnalyticsSwift

// figure out how to hook the table and cells up to delegate, dataSource, and other storyboard outlets

class SubmittedMovieListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "ButtonCell"
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    var tableRows: Int = 0
    var tableItems: Array = [String]()
    var orderedTitles = submittedMovieTitles.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        analytics.enqueue(TrackMessageBuilder(event: "Viewed Submitted Movie List").userId(uzer))
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this method will populate the table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ButtonCell
        
        //adding the item to table row
        cell.textLabel?.text = submittedMoviePlots[indexPath.row] as! String
        cell.detailTextLabel?.text = submittedMovieTitles[indexPath.row] as! String
        cell.tapAction = { (cell) in
            self.showAlertForRow(tableView.indexPathForCell(cell)!.row)
        }
        return cell
    }
    
    
    //this method will return the total rows count in the table view
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return submittedMoviePlots.count
    }
    
    func showAlertForRow(row: Int) {
        //  let item = tableView.cellForRowAtIndexPath(row)!.textLabel!.text!
        print("button tapped on row \(row)")
        let sharePlot = submittedMoviePlots[row]
        let shareTitle = submittedMovieTitles[row]
        
        let textToShare = "I added this movie plot to @emojisodes. Can you guess it? \(sharePlot)"
        let objectsToShare = [textToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        activityVC.popoverPresentationController?.sourceView = sender as! UIView
        self.presentViewController(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            if completed == true {
                self.analytics.enqueue(TrackMessageBuilder(event: "Shared Movie").properties(["movie": shareTitle, "outcome": "success", "place": "movieList"]).userId(uzer))
                self.analytics.flush()
            } else {
                self.analytics.enqueue(TrackMessageBuilder(event: "Shared Movie").properties(["movie": shareTitle, "outcome": "fail", "place": "movieList"]).userId(uzer))
                self.analytics.flush()
            }
        }
        
    }
    
    @IBAction func finishUpButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        analytics.flush()
    }
}
