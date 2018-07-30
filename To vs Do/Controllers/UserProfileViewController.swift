//
//  UserProfileViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/27/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendCountLabel: UILabel!
    @IBOutlet weak var userStatTableView: UITableView!
    @IBOutlet weak var editPhotoButton: UIBarButtonItem!
    
    let photoHelper = TVDPhotoHelper()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statTableViewCell", for: indexPath) as! StatTableViewCell
        
       return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Stats"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLabel.text = User.current.username
        photoHelper.completionHandler = { image in
            ProfilePicService.create(for: image)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ref = Database.database().reference().child("users").child(User.current.uid).child("profilePic").child("image_url")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let key = snapshot.value as? String
            if let key = key {
                let image = URL(string: key)
                self.userProfileImageView.af_setImage(withURL: image!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editPhotoButtonTapped(_ sender: UIBarButtonItem) {
        photoHelper.presentActionSheet(from: self)
        let ref = Database.database().reference().child("users").child(User.current.uid).child("profilePic").child("image_url")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let key = snapshot.value as? String
            if let key = key {
                let image = URL(string: key)
                self.userProfileImageView.af_setImage(withURL: image!)
            }
        }
    }
    
}
