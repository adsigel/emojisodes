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
    var allStickers = ["Slipie_angel", "Slipie_angry", "Slipie_giggle"]
    
    var stickerNames : [String] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        getAllStickers()
        determineStickers()
        self.stickers = [MSSticker]()
        self.stickers = loadStickers()
        print("gifArray is \(gifArray)")
    }
    
    override func numberOfStickersInStickerBrowserView(stickerBrowserView: MSStickerBrowserView) -> Int {
        return self.stickers.count
    }
    
    override func stickerBrowserView(stickerBrowserView: MSStickerBrowserView, stickerAtIndex index: Int) -> MSSticker {
        return self.stickers[index]
    }
    
    private func determineStickers() {
        for stickername in allStickers {
            if stickername.containsString("Slipie_a") {
                stickerNames.append(stickername)
            }
        }
    }
    
    func getAllStickers() -> [String] {
        var gifArray = [String]()
        
        let docsPath = NSBundle.mainBundle().resourcePath! + "/StickerGIFs"
        print("docsPath is \(docsPath)")
        let fileManager = NSFileManager.defaultManager()
        
        do {
            let gifArray = try fileManager.contentsOfDirectoryAtPath(docsPath)
        } catch {
            print(error)
        }
        return gifArray
    }
    
    private func loadStickers() -> [MSSticker] {
        
        var stickers = [MSSticker]()
        
        for stickerName in self.stickerNames {
            
            guard let url = NSBundle.mainBundle().URLForResource(stickerName as! String, withExtension: "png") else {
                fatalError("resource does not exist")
            }
            
            let sticker = try! MSSticker(contentsOfFileURL: url, localizedDescription: stickerName as! String)
            stickers.append(sticker)
        }
        
        return stickers
    }
}
