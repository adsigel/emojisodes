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

class MovieListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "CellIdentifier"
    var tableRows: Int = 0
    var tableItems: Array = [String]()
//    var movieTitles: Array = [String]()
//    var moviePlots: Array = [String]()
//    var movieList = [String:String]()
    
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
    
    
    //this method will populate the table view
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableRow = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        //adding the item to table row
        tableRow.textLabel?.text = moviePlots[indexPath.row] as! String
        tableRow.detailTextLabel?.text = movieTitles[indexPath.row] as! String
//        print("tableItems = \(tableItems)")
        return tableRow
    }
    
    
    //this method will return the total rows count in the table view
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return moviePlots.count
    }
    
    @IBAction func finishUpButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
