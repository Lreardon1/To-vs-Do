//
//  FriendService.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/31/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FriendsService {
    private static func sendFriendRequest(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let requestData = ["requests/\(user.uid)/\(currentUID)" : true]
        
        
        let ref = Database.database().reference()
        ref.updateChildValues(requestData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            success(error == nil)
        }
    }
    
    private static func acceptFriendRequest(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let friendData = ["friends/\(user.uid)/\(currentUID)" : true,
                          "friends/\(currentUID)/\(user.uid)": true ]
        
        
        
        let ref = Database.database().reference()
        ref.updateChildValues(friendData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            success(error == nil)
        }
    }
    
    private static func unfriendUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let unfriendData = ["friends/\(user.uid)/\(currentUID)" : NSNull(),
                            "friends/\(currentUID)/\(user.uid)": NSNull()]
        
        let ref = Database.database().reference()
        ref.updateChildValues(unfriendData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            success(error == nil)
        }
    }
    
    static func setIsFollowing(_ isFriendsWith: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFriendsWith {
            acceptFriendRequest(followee, forCurrentUserWithSuccess: success)
        } else {
            unfriendUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
    static func isUserFriendsWith(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        let ref = Database.database().reference().child("friends").child(user.uid)
        
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
