//
//  User.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/23/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: Codable {
    
    let uid: String
    let username: String
    var isFriend = false
    var profilePic: String
    
    private static var _current: User?
    
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        return currentUser
    }
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        self.profilePic = "https://firebasestorage.googleapis.com/v0/b/to-vs-do.appspot.com/o/DefaultUserPic%20(1).jpg?alt=media&token=63da55d4-aa76-4134-82b5-e99e6855a334"
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let profilePic = dict["image_url"] as? String
            else { return nil }
        self.uid = snapshot.key
        self.username = username
        self.profilePic = profilePic
    }
    
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            if let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
            }
        }
        _current = user
    }
}
