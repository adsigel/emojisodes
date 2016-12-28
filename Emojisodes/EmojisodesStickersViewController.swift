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

class EmojisodesStickersViewController : MSStickerBrowserViewController {
    
    var analytics = Analytics.create("8KlUfkkGBbR8SOKAqwCK7C23AZ43KkQj")
    var defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.adamdsigel.emojisodes")!
    var stickers : [MSSticker]!
    var gifArray : [String] = []
    var allMovies : [String] = []
    var stickerNames : Array = [String]()
    var userMovies = [String]()
    var newArray : Array = [String]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        buildAllMovies()
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
                    print("appending \(item) to \(stickerNames)")
                } else {
                    print("no extMovies to be found here")
                }
            }
            
        }
        
    }
    
    func buildAllMovies() -> [String] {
        let docsPath = NSBundle.mainBundle().resourcePath!
        print("docsPath is: \(docsPath)")
        let fileManager = NSFileManager.defaultManager()
        print("fileManager is: \(fileManager)")
        
        do {
            let docsArray = try fileManager.contentsOfDirectoryAtPath(docsPath)
            print("docsArray is: \(docsArray)")
            for item in docsArray {
                if item.hasSuffix(".gif") {
                    gifArray.append(item.stringByReplacingOccurrencesOfString(".gif", withString: ""))
                    print("gifArray is: \(gifArray)")
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
        
        analytics.enqueue(TrackMessageBuilder(event: "Loaded Stickers").userId(extUzer))
        analytics.flush()
        
        return stickers
    }
    
}
