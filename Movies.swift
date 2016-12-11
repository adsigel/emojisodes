//
//  Movies.swift
//  emojigame
//
//  Created by Adam Sigel on 8/3/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import Firebase

struct Movies {
    
    let key: String!
    let title: String!
    let plot: String!
    let hint: String!
    let addedByUser: String!
    let addedDate: String!
    let points: Int!
    var approved: Int!
//    var actors: String!
    
    // Initialize from arbitrary data
    init(title: String, plot: String, hint: String, addedDate: String, addedByUser: String, approved: Int, points: Int, key: String = ""
//        , actors: String
        ) {
        self.key = key
        self.title = title
        self.plot = plot
        self.hint = hint
        self.addedDate = addedDate
        self.addedByUser = addedByUser
        self.approved = approved
        self.points = points
//        self.actors = actors
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        title = snapshot.value!["title"] as! String
        plot = snapshot.value!["plot"] as! String
        hint = snapshot.value!["hint"] as! String
        addedDate = snapshot.value!["addedDate"] as! String
        addedByUser = snapshot.value!["addedByUser"] as! String
        approved = snapshot.value!["approved"] as! Int
        points = snapshot.value!["points"] as! Int
//        actors = snapshot.value!["actors"] as! String
    }
    
    
    func toAnyObject() -> AnyObject {
        return [
            "title": title,
            "plot": plot,
            "hint": hint,
            "addedDate": addedDate,
            "addedByUser": addedByUser,
            "approved": approved,
            "points": points,
//            "actors": actors
        ]
    }
    
}
