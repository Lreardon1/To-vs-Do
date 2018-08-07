//
//  UserService.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/24/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userData = ["username": username,
                        "image_url": "https://firebasestorage.googleapis.com/v0/b/to-vs-do.appspot.com/o/DefaultUserPic%20(1).jpg?alt=media&token=63da55d4-aa76-4134-82b5-e99e6855a334"]
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.updateChildValues(userData) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
    
    static func usersExcludingCurrentUser(completion: @escaping([User]) -> Void) {
        let currentUser = User.current
        let ref = Database.database().reference().child("users")
        let requestRef = Database.database().reference().child("friends").child(currentUser.uid)
        let blockRef = Database.database().reference().child("blockedUsers").child(currentUser.uid)
        
        var requestedUsers = [String]()
        var blockedUsers = [String]()
        
        requestRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : String]
                else {return completion([])}
            for item in snapshot {
                requestedUsers.append(item.value)
            }
        }
        
        blockRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : Any]
                else {return completion([])}
            for item in snapshot {
                blockedUsers.append(item.key)
            }
        }

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }

            let users = snapshot.compactMap(User.init).filter { $0.uid != currentUser.uid }

            var finalUsers = [User]()
            for user in users {
                if(!requestedUsers.contains(user.uid) && !blockedUsers.contains(user.uid)) {
                    finalUsers.append(user)
                }
            }
            
            let dispatchGroup = DispatchGroup()
            finalUsers.forEach { (user) in
                dispatchGroup.enter()

                FriendsService.isUserFriendsWith(user) { (isFriend) in
                    user.isFriend = isFriend
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main, execute: {
                completion(finalUsers)
            })
        })
    }
    
    static func requestedFriends(completion: @escaping([User]) -> Void) {
        let currentUser = User.current
        let ref = Database.database().reference().child("users")
        let requestRef = Database.database().reference().child("requests").child(currentUser.uid)
        let blockRef = Database.database().reference().child("blockedUsers").child(currentUser.uid)
        
        var requestedUsers = [String]()
        var blockedUsers = [String]()
        
        requestRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : String]
                else {return completion([])}
            for item in snapshot {
                requestedUsers.append(item.value)
            }
        }
        
        blockRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : Any]
                else {return completion([])}
            for item in snapshot {
                blockedUsers.append(item.key)
            }
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let users = snapshot.compactMap(User.init).filter { $0.uid != currentUser.uid }
            
            var finalUsers = [User]()
            for user in requestedUsers {
                for allUsers in users {
                    if(user == allUsers.uid && !blockedUsers.contains(user)) {
                        finalUsers.append(allUsers)
                    }
                }
            }
            
            let dispatchGroup = DispatchGroup()
            finalUsers.forEach { (user) in
                dispatchGroup.enter()
                
                FriendsService.isUserFriendsWith(user) { (isFriend) in
                    user.isFriend = isFriend
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(finalUsers)
            })
        })
    }
    
    static func friendsList(completion: @escaping([User]) -> Void) {
        let currentUser = User.current
        let ref = Database.database().reference().child("users")
        let requestRef = Database.database().reference().child("friends").child(currentUser.uid)
        
        var requestedUsers = [String]()
        
        requestRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : String]
                else {return completion([])}
            for item in snapshot {
                requestedUsers.append(item.value)
            }
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let users = snapshot.compactMap(User.init).filter { $0.uid != currentUser.uid }
            
            var finalUsers = [User]()
            for user in requestedUsers {
                for allUsers in users {
                    if(user == allUsers.uid) {
                        finalUsers.append(allUsers)
                    }
                }
            }
            
            let dispatchGroup = DispatchGroup()
            finalUsers.forEach { (user) in
                dispatchGroup.enter()
                
                FriendsService.isUserFriendsWith(user) { (isFriend) in
                    user.isFriend = isFriend
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(finalUsers)
            })
        })
    }
    
    static func searchForNewFriend(username: String, completion: @escaping([User]) -> Void) {
        var newUsers = [User]()
        
        UserService.usersExcludingCurrentUser { (users) in
            newUsers = users
        }
        
        var finalUsers = [User]()
        for user in newUsers {
            if(user.username == username) {
                finalUsers.append(user)
            }
        }
            
        let dispatchGroup = DispatchGroup()
        finalUsers.forEach { (user) in
            dispatchGroup.enter()
                
            FriendsService.isUserFriendsWith(user) { (isFriend) in
                user.isFriend = isFriend
                dispatchGroup.leave()
            }
        }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(finalUsers)
            })
    }
    
    static func searchForOldFriend(username: String, completion: @escaping([User]) -> Void) {
        let currentUser = User.current
        let ref = Database.database().reference().child("users")
        let requestRef = Database.database().reference().child("friends").child(currentUser.uid)
        
        var requestedUsers = [String]()
        
        requestRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : String]
                else {return completion([])}
            for item in snapshot {
                requestedUsers.append(item.value)
            }
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let users = snapshot.compactMap(User.init).filter { $0.uid != currentUser.uid }
            
            var finalUsers = [User]()
            for user in requestedUsers {
                for allUsers in users {
                    if(user == allUsers.uid) {
                        if(allUsers.username == username) {
                            finalUsers.append(allUsers)
                        }
                    }
                }
            }
            
            let dispatchGroup = DispatchGroup()
            finalUsers.forEach { (user) in
                dispatchGroup.enter()
                
                FriendsService.isUserFriendsWith(user) { (isFriend) in
                    user.isFriend = isFriend
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(finalUsers)
            })
        })
    }
}
