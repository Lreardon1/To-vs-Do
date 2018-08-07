//
//  ProfilePicService.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/27/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import Foundation

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct ProfilePicService {
    static func create(for image: UIImage) {
        let imageRef = StorageReference.newProfilePicReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }

            let urlString = downloadURL.absoluteString
            User.current.profilePic = urlString
            ProfilePic.create(forURLString: urlString)
        }
    }
}
