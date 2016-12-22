//: Playground - noun: a place where people can play

import UIKit
import Foundation


//var title = "d"
var plot = ""

var newArray : Array = [String]()

var allMovies = ["the net", "demolition man", "psycho", "inception", "the shawshank redemption"]

var userMovies = ["the net", "demolition man"]

for item in allMovies {
    if userMovies.contains(item) {
        newArray.append(item)
    }
}

print(newArray)