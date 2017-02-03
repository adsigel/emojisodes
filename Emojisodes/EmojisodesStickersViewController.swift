//
//  EmojisodesStickersViewController.swift
//  emojigame
//
//  Created by Adam Sigel on 12/19/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import Messages
import AnalyticsSwift
import Firebase

class EmojisodesStickersViewController : MSStickerBrowserViewController {
    
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    var defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.adamdsigel.emojisodes")!
    var stickers : [MSSticker]!
    var gifArray : [String] = []
    var allMovies : [String] = []
    var stickerNames : Array = [String]()
    var userMovies = [String]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if(FIRApp.defaultApp() == nil){
            FIRApp.configure()
        }
        print("gifRef is \(gifRef) as \(gifRef.dynamicType)")
        buildAllMovies()
        grabGifs()
        determineStickers()
        self.stickers = [MSSticker]()
        self.stickers = loadStickers()
    }
    
    override func numberOfStickersInStickerBrowserView(stickerBrowserView: MSStickerBrowserView) -> Int {
        return self.stickers.count
    }
    
    override func stickerBrowserView(stickerBrowserView: MSStickerBrowserView, stickerAtIndex index: Int) -> MSSticker {
        return self.stickers[index]
    }
    
    func determineStickers() {
        allMovies = gifArray
        print("allMovies is: \(allMovies)")
        if let extMovies = defaults.arrayForKey("extensionMovies") as? [String] {
            for item in allMovies {
                if extMovies.contains(item.capitalizedString) {
                    stickerNames.append(item)
//                    print("appending \(item) to \(stickerNames)")
                } else {
//                    print("no extMovies to be found here")
                }
            }
        }
        
    }
    
    
    func grabGifs() {
        // successfully returning the URL of a specific file in Firebase storage
        // TODO:
        // 1. Loop through the /gif child and get a URL for every file
        // 2. Compare the filenames of the gifs to the titles in extMovies
        // 3. Present the matches to the user (download all matches first?)
        let bigRef = gifRef.child("big.gif")
        bigRef.downloadURLWithCompletion { (url, error) in
            if let error = error {
                // handle the errors
                print("error getting download url: \(error)")
            } else {
                // get the download url
                print("download url is \(url!)")
            }
        }
    }
    

    
    func buildAllMovies() -> [String] {
        let docsPath = NSBundle.mainBundle().resourcePath!
        let fileManager = NSFileManager.defaultManager()
        
        do {
            let docsArray = try fileManager.contentsOfDirectoryAtPath(docsPath)
//            print("docsArray is: \(docsArray)")
            for item in docsArray {
                if item.hasSuffix(".gif") {
                    gifArray.append(item.stringByReplacingOccurrencesOfString(".gif", withString: ""))
//                    print("gifArray is: \(gifArray)")
                }
            }
        } catch {
            print(error)
        }
        
        return gifArray
    }
        
    private func loadStickers() -> [MSSticker] {
        
        for stickerName in stickerNames {
            guard let url = NSBundle.mainBundle().URLForResource(stickerName as! String, withExtension: "gif") else {
                fatalError("resource does not exist")
            }
            print("sticker url is \(url)")
            let sticker = try! MSSticker(contentsOfFileURL: url, localizedDescription: stickerName as! String)
            stickers.append(sticker)
        }
        
        
        
        return stickers
    }
    
}
