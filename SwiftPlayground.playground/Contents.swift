//: Playground - noun: a place where people can play

import UIKit
import Foundation


//var title = "d"
var plot = ""

var title = "The Day After Tomorrow"

var spacelessString = title.stringByReplacingOccurrencesOfString(" ", withString: "+")

let urlPath = NSURL(string: "https://www.omdbapi.com/?t=\(spacelessString)&tomatoes=true&plot=short&type=movie")!

//if title != "" && plot != "" {
//    print("This is okay.")
//} else {
//    print("Something is missing.")
//}

var movieValue = 105

var myDict = ["movie1": "plot1", "movie2": "plot2", "movie3": "plot3"]

myDict.count
