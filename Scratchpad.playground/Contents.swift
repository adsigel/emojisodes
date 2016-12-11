//: Playground - noun: a place where people can play

import UIKit
import Foundation

var str = "Hello, playground"

//Swift recap

var someVariable = "aVariable"
let someConstant = 20

someVariable = "anotherString"
//someConstant = 15

var fruitsArray = ["apples", "bananas", "kiwis"]
fruitsArray.append("strawberries")

fruitsArray

//Optional



var optionalString: String? = "hello"
optionalString = nil

fruitsArray[1]

//Random Number Generation

var randomNumber = Int(arc4random_uniform(10))

//UIColor

var redColor = UIColor(red: 223/255.0, green: 86/255.0, blue: 94/255.0, alpha: 1.0)


//Debug

let colorsArray = [
    UIColor(red: 200/255.0, green: 100/255.0, blue: 12/255.0, alpha: 1.0),
    UIColor(red: 180/255.0, green: 175/255.0, blue: 253/255.0, alpha: 1.0),
    UIColor(red: 20/255.0, green: 68/255.0, blue: 123/255.0, alpha: 1.0),
    UIColor(red: 38/255.0, green: 210/255.0, blue: 112/255.0, alpha: 1.0),
]

colorsArray.count
UInt32(colorsArray.count)
var randomInt = Int(arc4random_uniform(UInt32(colorsArray.count)))



//func randomColor() -> UIColor {
//    var unassignedArrayCount = UInt32(colorsArray.count)
//    var unassignedRandomNumber = arc4random_uniform(unassignedArrayCount)
//    var randomNumber = Int(unassignedRandomNumber)
//    return colorsArray[randomNumber]
//


var testDict = ["name": ""]

testDict["name"]

var name = testDict["name"]!

print(name)

if name != "\n" {
    print("name is \(name)")
} else {
    print("name is empty")
}

var title = "spider-man"

if title.hasPrefix("the") == true {
   title = (title as NSString).stringByReplacingOccurrencesOfString("the ", withString: "")
}


title.score("spider man", fuzziness: 0.9)

public extension String
{
    func score(word: String, fuzziness: Double? = nil) -> Double
    {
        // If the string is equal to the word, perfect match.
        if self == word {
            return 1
        }
        
        //if it's not a perfect match and is empty return 0
        if word.isEmpty || self.isEmpty {
            return 0
        }
        
        var
        runningScore = 0.0,
        charScore = 0.0,
        finalScore = 0.0,
        string = self,
        lString = string.lowercaseString,
        strLength = string.characters.count,
        lWord = word.lowercaseString,
        wordLength = word.characters.count,
        idxOf: String.Index!,
        startAt = lString.startIndex,
        fuzzies = 1.0,
        fuzzyFactor = 0.0,
        fuzzinessIsNil = true
        
        // Cache fuzzyFactor for speed increase
        if let fuzziness = fuzziness {
            fuzzyFactor = 1 - fuzziness
            fuzzinessIsNil = false
        }
        
        for i in 0 ..< wordLength {
            // Find next first case-insensitive match of word's i-th character.
            // The search in "string" begins at "startAt".
            if let range = lString.rangeOfString(
                String(lWord[lWord.startIndex.advancedBy(i)] as Character),
                options: NSStringCompareOptions.CaseInsensitiveSearch,
                range: Range<String.Index>(startAt..<lString.endIndex),
                locale: nil
                ) {
                // start index of word's i-th character in string.
                idxOf = range.startIndex
                if startAt == idxOf {
                    // Consecutive letter & start-of-string Bonus
                    charScore = 0.7
                }
                else {
                    charScore = 0.1
                    
                    // Acronym Bonus
                    // Weighing Logic: Typing the first character of an acronym is as if you
                    // preceded it with two perfect character matches.
                    if string[idxOf.advancedBy(-1)] == " " {
                        charScore += 0.8
                    }
                }
            }
            else {
                // Character not found.
                if fuzzinessIsNil {
                    // Fuzziness is nil. Return 0.
                    return 0
                }
                else {
                    fuzzies += fuzzyFactor
                    continue
                }
            }
            
            // Same case bonus.
            if (string[idxOf] == word[word.startIndex.advancedBy(i)]) {
                charScore += 0.1
            }
            
            // Update scores and startAt position for next round of indexOf
            runningScore += charScore
            startAt = idxOf.advancedBy(1)
        }
        
        // Reduce penalty for longer strings.
        finalScore = 0.5 * (runningScore / Double(strLength) + runningScore / Double(wordLength)) / fuzzies
        
        if (lWord[lWord.startIndex] == lString[lString.startIndex]) && (finalScore < 0.85) {
            finalScore += 0.15
        }
        
        return finalScore
    }
}

