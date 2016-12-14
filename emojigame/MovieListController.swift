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
    var movieTitles: Array = [String]()
    var moviePlots: Array = [String]()
//    var movieList = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildMovieList()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buildMovieList() {
        // get list of movies the user has completed
        userRef.child(uzer).child("exclude").observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot!) in
            var count = 0
            count += Int(snapshot.childrenCount)
            print("count of child nodes is \(count)")
            self.tableRows = count
        })
        var excludeDict = userDict["exclude"]! as! [String: AnyObject]
        print("exclusion dict is \(userDict["exclude"]!)")
        tableItems = Array(excludeDict.keys)
        print ("tableItems is \(tableItems)")
//        print("movieList is \(movieList)")
//        var movieListRows = movieList.keys
//        print("movieListRows is \(movieListRows)")
    }
    
    
    //this method will populate the table view
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableRow = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
        //adding the item to table row
        tableRow.textLabel?.text = tableItems[indexPath.row] as! String
//        print("tableItems = \(tableItems)")
        return tableRow
    }
    
    
    //this method will return the total rows count in the table view
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    @IBAction func finishUpButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
