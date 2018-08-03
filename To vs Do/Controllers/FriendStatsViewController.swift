//
//  FriendStatsViewController.swift
//  To vs Do
//
//  Created by Leith Reardon on 7/31/18.
//  Copyright © 2018 Leith Reardon. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FriendStatsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendStatTableView: UITableView!
    @IBOutlet weak var searchFriendsSearchBar: UISearchBar!
    
    var users = [User]()
    var toDoTodayCount: Int? {
        didSet {
            friendStatTableView.reloadData()
        }
    }
    var completedTodayCount: Int? {
        didSet {
            friendStatTableView.reloadData()
        }
    }
    var dailyAverage: Double? {
        didSet{
            friendStatTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.friendsList { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.friendStatTableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        UserService.friendsList { [unowned self] (users) in
            self.users = users
            
            DispatchQueue.main.async {
                self.friendStatTableView.reloadData()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        if(searchBar.text != nil) {
            UserService.searchForOldFriend(username: searchBar.text!) { [unowned self] (users) in
                self.users = users
                
                DispatchQueue.main.async {
                    self.friendStatTableView.reloadData()
                }
            }
        }
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendStatTableViewCell", for: indexPath) as! FriendStatTableViewCell
        let friend  = users[indexPath.row]
        cell.friendProfileImageView.af_setImage(withURL: URL(string: friend.profilePic)!)
        cell.friendUsernameLabel.text = friend.username
        cell.friendCompletedLabel.text = "Completed Today: " + String(getCompletedTodayCount(user: friend))
        cell.friendToDoLabel.text = "To Do Today: " + String(getToDoTodayCount(user: friend))
        cell.friendAverageLabel.text = "Average: " + String(getAverageCount(user: friend))
        return cell
    }
    
    func getToDoTodayCount(user: User) -> Int {
        let ref = Database.database().reference().child("stats").child(user.uid).child("toDoToday")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.toDoTodayCount = snapshot.value as? Int
        }
        if let count = self.toDoTodayCount {
            return count
        } else {
            return 0
        }
    }
    
    func getCompletedTodayCount(user: User) -> Int {
        let ref = Database.database().reference().child("stats").child(user.uid).child("completedToday")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.completedTodayCount = snapshot.value as? Int
        }
        if let count = self.completedTodayCount {
            return count
        } else {
            return 0
        }
    }
    
    func getAverageCount(user: User) -> Double {
        let ref = Database.database().reference().child("stats").child(user.uid).child("dailyAverage")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            self.dailyAverage = snapshot.value as? Double
        }
        if let count = self.dailyAverage {
            return count
        } else {
            return 0
        }
    }
}
