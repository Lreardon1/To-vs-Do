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
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        searchFriendsSearchBar.resignFirstResponder()
        searchFriendsSearchBar.setShowsCancelButton(false, animated: true)
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Report as Inappropriate") { (action, indexPath) in
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to report this user for inapporpiate content?", preferredStyle: .alert)
            
            let reportAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                let flaggedUser = self.users[indexPath.row]
                let flaggedUserRef = Database.database().reference().child("flaggedUsers").child(flaggedUser.uid)
                let flaggedDict = ["image_url" : flaggedUser.profilePic,
                                   "username" : flaggedUser.username,
                                   "reporter_uids/\(User.current.uid)": true] as [String : Any]
                flaggedUserRef.updateChildValues(flaggedDict)
                
                let flagCountRef = flaggedUserRef.child("flag_count")
                flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                    let currentCount = mutableData.value as? Int ?? 0
                    
                    mutableData.value = currentCount + 1
                    
                    return TransactionResult.success(withValue: mutableData)
                })
            })
            alertController.addAction(reportAction)
            
            let declineAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alertController.addAction(declineAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        let block = UITableViewRowAction(style: .normal, title: "Block User") { (action, indexPath) in
            let alertController = UIAlertController(title: nil, message: "Are you sure you want to block this user?", preferredStyle: .alert)
            
            let blockAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                let blockedUser = self.users[indexPath.row]
                let blockedUserRef = Database.database().reference().child("blockedUsers").child(User.current.uid)
                let blockedDict = [blockedUser.uid: true]
                
                blockedUserRef.updateChildValues(blockedDict)
                
                FriendsService.setIsFriend(false, fromCurrentUserTo: self.users[indexPath.row]) { (success) in
                    guard success else { return }
                }
                
                UserService.friendsList { [unowned self] (users) in
                    self.users = users
                    
                    DispatchQueue.main.async {
                        self.friendStatTableView.reloadData()
                    }
                }
            })
            alertController.addAction(blockAction)
            
            let declineAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alertController.addAction(declineAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.897116363, green: 0.1273201406, blue: 0, alpha: 1)
        block.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return [delete, block]
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
                cell.friendCompletedLabel.text = "Completed: " + String(count)
            } else {
                cell.friendCompletedLabel.text = "Completed: 0"
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
        ref.child("totalToDo").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as? Int
            if let count = count {
                cell.friendTotalToDoLabel.text = "Total To Do: " + String(count)
            } else {
                cell.friendTotalToDoLabel.text = "Total To Do: 0"
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
