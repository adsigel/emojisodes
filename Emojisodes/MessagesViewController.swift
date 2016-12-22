//
//  MessagesViewController.swift
//  Emojisodes
//
//  Created by Adam Sigel on 12/19/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import UIKit
import Messages

var movieTitles: Array = [String]()

class MessagesViewController: MSMessagesAppViewController {
    
    var stickerBrowser: MSStickerBrowserView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var defaults = NSUserDefaults(suiteName: "group.com.emojisodes")
        defaults?.synchronize()
        
        // Check for null value before setting
        if let movieTitles = defaults!.stringForKey("movieTitles") {
            print("MessagesViewController: synchronized movieTitles from \(movieTitles)")
        }
        else {
            print("MessagesViewController: Cannot sychronize movieTitles")
        }
//        buildMovieList()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    private func setupStickerBrowser(){
        if stickerBrowser == nil{
            //1. Sticker Browser Initialization
            stickerBrowser = MSStickerBrowserView()
            view.addSubview(stickerBrowser!)
        }
    }
    
//    func buildMovieList() {
//        var defaults = NSUserDefaults(suiteName: "group.com.emojisodes")
//        defaults?.synchronize()
//        
//        // Check for null value before setting
//        if let syncTitles = defaults!.stringForKey("movieTitles") {
//            print("synchronized movieTitles as \(movieTitles)")
//        }
//        else {
//            print("Cannot sychronize movieTitles")
//        }
//    }


    
    func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
