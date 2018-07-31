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
        let userUsername = ["username": username]
        
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userUsername) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
        StatCalculatorService.calculateStats()
//        let image = UIImage(named: "ic_account_circle")
//        ProfilePicService.create(for: image!)
    }
}
