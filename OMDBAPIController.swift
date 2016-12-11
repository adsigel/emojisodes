//
//  OMDBAPIController.swift
//  Films
//
//  Created by Dulio Denis on 8/14/15.
//  Copyright (c) 2015 Dulio Denis. All rights reserved.
//
import UIKit


// Specify the OMDB API Protocol

protocol OMDBAPIControllerDelegate {
    func didFinishOMDBSearch(result: Dictionary<String, String>)
}


class OMDBAPIController {
    // Optional delegate property adheres to OMDB API protocol
    var delegate: OMDBAPIControllerDelegate?
    
    // initializer accepts optional delegate and sets it
    init(delegate: OMDBAPIControllerDelegate?) {
        self.delegate = delegate
    }
    
    
    func searchOMDB(forContent:String) {
        var spacelessString = forContent.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let urlPath = NSURL(string: "https://www.omdbapi.com/?t=\(spacelessString)&tomatoes=true&plot=short&type=movie")!
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(urlPath) {
            data, response, error -> Void in
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                                print(jsonResult)
                                if let apiDelegate = self.delegate {
                                    
                                    // send the json results to the delegate on the main queue
                                    dispatch_async(dispatch_get_main_queue()) {
                                        apiDelegate.didFinishOMDBSearch(jsonResult as! Dictionary<String, String>)
                                    }
                                }
                                
                            }
                        } catch let JSONError as NSError {
                            print(JSONError)
                        }
                    } else if (httpResponse.statusCode == 422) {
                        print("422 Error Occurred...")
                    }
                } else {
                    print("Can't cast response to NSHTTPURLResponse")
                }
            }
        }
        task.resume()
    }
}