//
//  ProfilePic.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/27/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot

class ProfilePic {
    var key: String?
    let imageURL: String
    
    var dictValue: [String : Any] {
        
        return ["image_url" : imageURL]
    }
    
    init(imageURL: String) {
        self.imageURL = imageURL
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let imageURL = dict["image_url"] as? String
            else { return nil }
        
        self.key = snapshot.key
        self.imageURL = imageURL
    }
    
    public static func create(forURLString urlString: String) {
        let currentUser = User.current
        let profilePic = ProfilePic(imageURL: urlString)
        let dict = profilePic.dictValue
        
        let postRef = Database.database().reference().child("users").child(currentUser.uid).child("profilePic")
        postRef.setValue(dict)
    }
}
