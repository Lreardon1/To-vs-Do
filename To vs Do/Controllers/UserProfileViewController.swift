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
    var toDoTodayCount: Int? {
        didSet {
            userStatTableView.reloadData()
        }
    }
    var completedTodayCount: Int? {
        didSet {
            userStatTableView.reloadData()
        }
    }
    var dailyAverage: Double? {
        didSet {
            userStatTableView.reloadData()
        }
    }
    var friendCount: Int? {
        didSet {
            friendCountLabel.text = "You have \(String(getFriendCount())) friends"
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statTableViewCell", for: indexPath) as! StatTableViewCell
        cell.toDoTodayCountLabel.text = "To Do Today: \(String(getToDoTodayCount())) items"
        cell.completedTodayCountLabel.text = "Completed Today: \(String(getCompletedTodayCount())) items"
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Stats"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLabel.text = User.current.username
        friendCountLabel.text = "You have \(String(getFriendCount())) friends"
        photoHelper.completionHandler = { image in
            ProfilePicService.create(for: image)
        }
        userStatTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ref = Database.database().reference().child("users").child(User.current.uid).child("image_url")

        ref.observeSingleEvent(of: .value) { (snapshot) in
            let key = snapshot.value as? String
            if let key = key {
                let image = URL(string: key)
                self.userProfileImageView.af_setImage(withURL: image!)
            }
        }
        friendCountLabel.text = "You have \(String(getFriendCount())) friends"
        StatCalculatorService.calculateStats()
        userStatTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editPhotoButtonTapped(_ sender: UIBarButtonItem) {
        photoHelper.presentActionSheet(from: self)
        let ref = Database.database().reference().child("users").child(User.current.uid).child("image_url")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let key = snapshot.value as? String
            if let key = key {
                let image = URL(string: key)
                self.userProfileImageView.af_setImage(withURL: image!)
            }
        }
    }
    
    func getToDoTodayCount() -> Int {
        let ref = Database.database().reference().child("stats").child(User.current.uid).child("toDoToday")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.toDoTodayCount = snapshot.value as? Int
        }
        if let count = self.toDoTodayCount {
            return count
        } else {
            return 0
        }
    }
    
    func getCompletedTodayCount() -> Int {
        let ref = Database.database().reference().child("stats").child(User.current.uid).child("completedToday")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.completedTodayCount = snapshot.value as? Int
        }
        if let count = self.completedTodayCount {
            return count
        } else {
            return 0
        }
    }
    
    func getAverageCount() -> Double {
        let ref = Database.database().reference().child("stats").child(User.current.uid).child("dailyAverage")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.dailyAverage = snapshot.value as? Double
        }
        if let count = self.dailyAverage {
            return count
        } else {
            return 0
        }
    }
    
    func getFriendCount() -> Int{
        let ref = Database.database().reference().child("friends").child(User.current.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.value as? [String : Any]
                else { return }
            self.friendCount = snapshot.count
        }
        if let count = self.friendCount {
            return count
        } else {
            return 0
        }
    }
}
