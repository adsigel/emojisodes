//: Playground - noun: a place where people can play

import UIKit
import Foundation


var plot = ""

var movieDict = ["title": "Father of the Bride", "year": "1991", "actors": "Steve Martin, Diane Keaton", "plot": "💱➕🔈"]

movieDict["year"]
movieDict["plot"]!
print(movieDict["plot"]!)
print(movieDict["year"]!)

movieDict["quote"]

var newArray : Array = [String]()

var allMovies = ["the net", "demolition man", "psycho", "inception", "the shawshank redemption"]

var extMovies = ["The Net", "Demolition Man", "Aladdin"]

var movie = "the net"

movie.capitalized

for item in allMovies {
    if extMovies.contains(item.capitalized) {
        newArray.append(item)
    }
}

print(newArray)
