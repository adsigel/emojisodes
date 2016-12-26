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
    
    var defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.com.adamdsigel.emojisodes")!
    var stickers : [MSSticker]!
    var gifArray : [String] = []
    // TODO: Make allMovies a dynamic array based on what's in the file manager
    var allMovies = ["the net", "demolition man", "psycho", "poltergeist", "you've got mail", "the shawshank redemption", "ferris bueller's day off", "back to the future", "the three amigos", "wall-e", "se7en", "spider-man", "forrest gump", "thor", "inception", "big", "face off", "ace ventura pet detective", "kindergarten cop", "the wizard of oz", "pulp fiction"]
    var stickerNames : Array = [String]()
    var userMovies = [String]()
    var newArray : Array = [String]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
//        getAllStickers()
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
        // TODO: This function should append only the stickernames of movies the user has gotten right
//        for item in allMovies {
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
    
    func getAllStickers() -> [String] {
        // TODO: Fix this function, should build the array allStickers based on the GIFs in the file manager
//        var gifArray = [String]()
        let fileManager = NSFileManager.defaultManager()
//        guard let url = NSBundle.mainBundle().URLForResource(nil, withExtension: "gif") else {
//            fatalError("resource does not exist")
//        }
//        print("bundle URL is \(url)")
        let url = NSBundle.mainBundle() as! NSURL
        let contents = try! fileManager.contentsOfDirectoryAtURL(url, includingPropertiesForKeys: [NSURLNameKey, NSURLIsDirectoryKey], options: .SkipsHiddenFiles)
        
        for item in contents
        {
            gifArray.append(item.lastPathComponent!)
            print("gifArray is now \(gifArray)")
        }
        return gifArray
    }
        
    private func loadStickers() -> [MSSticker] {
        
        for stickerName in stickerNames {
            print ("url is \(NSBundle.mainBundle().resourcePath!.stringByAppendingString(""))")
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
