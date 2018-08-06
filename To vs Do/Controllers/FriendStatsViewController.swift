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
        
        let ref = Database.database().reference().child("stats").child(friend.uid)
        ref.child("completedToday").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int
            if let count = count {
                cell.friendCompletedLabel.text = "Completed Today: " + String(count)
            } else {
                cell.friendCompletedLabel.text = "Completed Today: 0"
            }
        }
        
        ref.child("toDoToday").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int
            if let count = count {
                cell.friendToDoLabel.text = "To Do Today: " + String(count)
            } else {
                cell.friendToDoLabel.text = "To Do Today: 0"
            }
        }
        
        ref.child("dailyAverage").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int
            if let count = count {
                cell.friendAverageLabel.text = "Average: " + String(count)
            } else {
                cell.friendAverageLabel.text = "Average: 0"
            }
        }
        return cell
    }
}
