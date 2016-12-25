//
//  EmojisodesStickersViewController.swift
//  emojigame
//
//  Created by Adam Sigel on 12/19/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import Messages

class EmojisodesStickersViewController : MSStickerBrowserViewController {
    
    var stickers : [MSSticker]!
    var gifArray : [String] = []
    // TODO: Make allMovies a dynamic array based on what's in the file manager
    var allMovies = ["the net", "demolition man"]
    var userMovies = [String]()
    
    var stickerNames : [String] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        extMovies = ["the net"]
        userMovies = extMovies
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
    
    private func determineStickers() {
        // TODO: This function should append only the stickernames of movies the user has gotten right
        for item in allMovies {
            if userMovies.contains(item) {
                stickerNames.append(item)
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
        }
        return gifArray
    }
        
    private func loadStickers() -> [MSSticker] {
        
        var stickers = [MSSticker]()
        print("stickerNames is \(stickerNames)")
        
        for stickerName in self.stickerNames {
            
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
