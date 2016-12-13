//
//  MovieListController.swift
//  emojigame
//
//  Created by Adam Sigel on 12/13/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import UIKit

class MovieListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "CellIdentifier"
//    var fruits: [String] = []
    
    var tableItems = ["Swift","Python","PHP","Java","JavaScript","C#"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableRow.textLabel?.text = tableItems[indexPath.row]
        print("tableItems = \(tableItems)")
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
