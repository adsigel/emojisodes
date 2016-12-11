//
//  Users.swift
//  emojigame
//
//  Created by Adam Sigel on 8/3/16.
//  Copyright © 2016 Adam Sigel. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let displayName: String
    let email: String
    let score: Int
    let addedDate: String
    
    // Initialize from Firebase
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
        displayName = authData.displayName!
        score = 0
        addedDate = ""
    }
    
    // Initialize from arbitrary data
    init(uid: String, email: String, displayName: String, score: Int, addedDate: String) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.score = score
        self.addedDate = addedDate
        
    }
    
    func toAnyObjectUser() -> AnyObject {
        return [
            "uid": uid,
            "displayName": displayName,
            "email": email,
            "score": score,
            "addedDate": addedDate
        ]
    }
}