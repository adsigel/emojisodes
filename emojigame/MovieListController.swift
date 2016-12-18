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
import TwitterKit

class MovieListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "ButtonCell"
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    var tableRows: Int = 0
    var tableItems: Array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableItems = movieTitles
//        print("tableItems is \(tableItems)")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bragFromList(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!)! as UITableViewCell
        print(currentCell.textLabel!.text)
        let composer = TWTRComposer()
        
        composer.setText("I'm playing @emojisodes and I figured out what movie this is! \(currentCell.textLabel!.text)")
        
        // Called from a UIViewController
        composer.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
                self.analytics.enqueue(TrackMessageBuilder(event: "Bragged").properties(["movie": movieDict["title"]!, "outcome": "fail"]).userId(uzer))
            }
            else {
                print("Sending tweet!")
                self.analytics.enqueue(TrackMessageBuilder(event: "Bragged").properties(["movie": movieDict["title"]!, "outcome": "success"]).userId(uzer))
            }
        }
        
    }
    
    //this method will populate the table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ButtonCell
        
        //adding the item to table row
        cell.textLabel?.text = moviePlots[indexPath.row] as! String
        cell.detailTextLabel?.text = movieTitles[indexPath.row] as! String
        cell.tapAction = { (cell) in
            self.showAlertForRow(tableView.indexPathForCell(cell)!.row)
        }
        return cell
    }
    
    
    //this method will return the total rows count in the table view
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return moviePlots.count
    }
        
    func showAlertForRow(row: Int) {
//        let item = tableView.cellForRowAtIndexPath(row)!.textLabel!.text!
        print("button tapped on row \(row)")
        let sharePlot = moviePlots[row]
        let composer = TWTRComposer()
        
        composer.setText("I'm playing @emojisodes and I figured out what movie this is! \(sharePlot)")
        
        // Called from a UIViewController
        composer.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
                self.analytics.enqueue(TrackMessageBuilder(event: "Bragged").properties(["movie": movieDict["title"]!, "outcome": "fail", "place": "movieList"]).userId(uzer))
            }
            else {
                print("Sending tweet!")
                self.analytics.enqueue(TrackMessageBuilder(event: "Bragged").properties(["movie": movieDict["title"]!, "outcome": "success", "place": "movieList"]).userId(uzer))
            }
        }
    }
    
    func finishUpButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
